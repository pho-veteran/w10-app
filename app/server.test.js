const test = require("node:test");
const assert = require("node:assert/strict");
const http = require("node:http");
const { createApp, createNoteStore } = require("./server");

async function startTestServer() {
  const app = createApp({ noteStore: createNoteStore() });

  return await new Promise((resolve, reject) => {
    const server = app.listen(0, "127.0.0.1", () => {
      resolve(server);
    });

    server.on("error", reject);
  });
}

async function request(server, requestPath, options = {}) {
  const address = server.address();
  const body = options.body ? JSON.stringify(options.body) : undefined;

  return await new Promise((resolve, reject) => {
    const req = http.request(
      {
        hostname: "127.0.0.1",
        port: address.port,
        path: requestPath,
        method: options.method || "GET",
        headers: {
          ...(body ? { "content-type": "application/json", "content-length": Buffer.byteLength(body) } : {}),
          ...(options.headers || {})
        }
      },
      (res) => {
        let responseBody = "";

        res.setEncoding("utf8");
        res.on("data", (chunk) => {
          responseBody += chunk;
        });
        res.on("end", () => {
          resolve({
            statusCode: res.statusCode,
            headers: res.headers,
            body: responseBody
          });
        });
      }
    );

    req.on("error", reject);

    if (body) {
      req.write(body);
    }

    req.end();
  });
}

async function withServer(callback) {
  const server = await startTestServer();

  try {
    await callback(server);
  } finally {
    server.close();
  }
}

test("GET /api/health returns ok payload", async () => {
  await withServer(async (server) => {
    const response = await request(server, "/api/health");
    assert.equal(response.statusCode, 200);
    assert.deepEqual(JSON.parse(response.body), { status: "ok" });
  });
});

test("GET /api/notes returns shared notes array", async () => {
  await withServer(async (server) => {
    const response = await request(server, "/api/notes");
    const payload = JSON.parse(response.body);

    assert.equal(response.statusCode, 200);
    assert.ok(Array.isArray(payload.notes));
    assert.ok(payload.notes.length >= 1);
  });
});

test("POST /api/notes creates a note", async () => {
  await withServer(async (server) => {
    const response = await request(server, "/api/notes", {
      method: "POST",
      body: { text: "Remember the old road." }
    });
    const payload = JSON.parse(response.body);

    assert.equal(response.statusCode, 201);
    assert.equal(payload.note.text, "Remember the old road.");
    assert.ok(payload.note.id);
    assert.ok(payload.note.createdAt);
  });
});

test("POST /api/notes rejects blank text", async () => {
  await withServer(async (server) => {
    const response = await request(server, "/api/notes", {
      method: "POST",
      body: { text: "   " }
    });
    const payload = JSON.parse(response.body);

    assert.equal(response.statusCode, 400);
    assert.equal(payload.error, "Note text is required.");
  });
});

test("DELETE /api/notes/:id removes a note", async () => {
  await withServer(async (server) => {
    const created = await request(server, "/api/notes", {
      method: "POST",
      body: { text: "This note will burn." }
    });
    const note = JSON.parse(created.body).note;

    const deleted = await request(server, `/api/notes/${note.id}`, { method: "DELETE" });
    const notes = await request(server, "/api/notes");

    assert.equal(deleted.statusCode, 204);
    assert.equal(JSON.parse(notes.body).notes.some((item) => item.id === note.id), false);
  });
});

test("GET /metrics returns Prometheus metrics", async () => {
  await withServer(async (server) => {
    await request(server, "/api/health");
    const response = await request(server, "/metrics");

    assert.equal(response.statusCode, 200);
    assert.match(response.headers["content-type"], /text\/plain/);
    assert.match(response.body, /process_cpu_user_seconds_total|nodejs_/);
    assert.match(response.body, /http_requests_total/);
    assert.match(response.body, /http_request_duration_seconds/);
  });
});

test("GET /api/debug/infra returns deployment metadata", async () => {
  process.env.PROJECT_NAME = "ci-cd-lab";
  process.env.ENVIRONMENT = "demo";
  process.env.NODE_PORT = "30080";

  await withServer(async (server) => {
    const response = await request(server, "/api/debug/infra");
    const payload = JSON.parse(response.body);

    assert.equal(response.statusCode, 200);
    assert.equal(payload.projectName, "ci-cd-lab");
    assert.equal(payload.environment, "demo");
    assert.equal(payload.nodePort, "30080");
    assert.match(payload.requestPath, /ALB/);
    assert.ok(payload.timestamp);
  });

  delete process.env.PROJECT_NAME;
  delete process.env.ENVIRONMENT;
  delete process.env.NODE_PORT;
});

test("GET / falls back to note taker html", async () => {
  await withServer(async (server) => {
    const response = await request(server, "/");

    assert.equal(response.statusCode, 200);
    assert.match(response.headers["content-type"], /text\/html/);
    assert.match(response.body, /Scriptoria/);
    assert.match(response.body, /Add a note/);
  });
});

test("GET static assets serves frontend files", async () => {
  await withServer(async (server) => {
    const script = await request(server, "/app.js");
    const styles = await request(server, "/styles.css");

    assert.equal(script.statusCode, 200);
    assert.match(script.headers["content-type"], /javascript/);
    assert.equal(styles.statusCode, 200);
    assert.match(styles.headers["content-type"], /css/);
  });
});

test("POST /api/debug/inject-errors increments error counter", async () => {
  await withServer(async (server) => {
    const response = await request(server, "/api/debug/inject-errors", { method: "POST" });
    const payload = JSON.parse(response.body);

    assert.equal(response.statusCode, 200);
    assert.ok(payload.injected > 0);
    assert.ok(payload.eta);

    const metrics = await request(server, "/metrics");
    assert.match(metrics.body, /http_requests_total\{[^}]*status_code="500"[^}]*\}/);
  });
});
