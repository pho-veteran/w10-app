const express = require("express");
const fs = require("fs");
const path = require("path");
const { Client } = require("pg");
const promClient = require("prom-client");

function getRouteLabel(req) {
  if (req.route?.path) {
    return req.route.path;
  }

  if (req.path === "/") {
    return "*";
  }

  if (req.path.includes(".")) {
    return "static";
  }

  return "unmatched";
}

function createMetrics() {
  const registry = new promClient.Registry();

  promClient.collectDefaultMetrics({ register: registry });

  const requestCounter = new promClient.Counter({
    name: "http_requests_total",
    help: "Total number of HTTP requests",
    labelNames: ["method", "route", "status_code"],
    registers: [registry]
  });

  const requestDuration = new promClient.Histogram({
    name: "http_request_duration_seconds",
    help: "HTTP request duration in seconds",
    labelNames: ["method", "route", "status_code"],
    registers: [registry]
  });

  return {
    registry,
    requestCounter,
    observeRequest(req, res, durationSeconds) {
      const labels = {
        method: req.method,
        route: getRouteLabel(req),
        status_code: String(res.statusCode)
      };

      requestCounter.inc(labels);
      requestDuration.observe(labels, durationSeconds);
    }
  };
}

function createNoteStore() {
  const notes = [
    {
      id: "seed-welcome",
      text: "Welcome, scribe. Your notes live on this backend until the server restarts.",
      createdAt: new Date().toISOString(),
      updatedAt: new Date().toISOString()
    }
  ];

  return {
    list() {
      return [...notes].sort((left, right) => right.createdAt.localeCompare(left.createdAt));
    },
    create(text) {
      const now = new Date().toISOString();
      const note = {
        id: `${Date.now().toString(36)}-${Math.random().toString(36).slice(2, 8)}`,
        text,
        createdAt: now,
        updatedAt: now
      };

      notes.push(note);
      return note;
    },
    delete(id) {
      const index = notes.findIndex((note) => note.id === id);

      if (index === -1) {
        return false;
      }

      notes.splice(index, 1);
      return true;
    }
  };
}

function readDbSecret(secretDir) {
  const keys = ["host", "port", "database", "username", "password"];
  const values = {};

  for (const key of keys) {
    values[key] = fs.readFileSync(path.join(secretDir, key), "utf8").trim();
  }

  return values;
}

function createDbHealthChecker(options = {}) {
  const secretDir = options.secretDir || process.env.DB_SECRET_DIR || "/etc/db-secret";
  const connectionTimeoutMillis = Number(process.env.DB_CONNECT_TIMEOUT_MS || 2000);

  return async function checkDbHealth() {
    const secret = readDbSecret(secretDir);
    const client = new Client({
      host: secret.host,
      port: Number(secret.port),
      database: secret.database,
      user: secret.username,
      password: secret.password,
      connectionTimeoutMillis
    });

    try {
      await client.connect();
      const result = await client.query("select now() as server_time, current_database() as database, current_user as username");
      const row = result.rows[0];

      return {
        dbConnected: true,
        database: row.database,
        user: row.username,
        host: secret.host,
        serverTime: row.server_time,
        secretSource: secretDir
      };
    } finally {
      await client.end().catch(() => {});
    }
  };
}

function createApp(options = {}) {
  const app = express();
  const projectName = process.env.PROJECT_NAME || "p2-w10-lab";
  const environment = process.env.ENVIRONMENT || "lab";
  const nodePort = process.env.NODE_PORT || "30080";
  const noteStore = options.noteStore || createNoteStore();
  const dbHealthChecker = options.dbHealthChecker || createDbHealthChecker();
  const metrics = createMetrics();

  app.use(express.json({ limit: "32kb" }));

  app.use((req, res, next) => {
    const startedAt = Date.now();

    res.on("finish", () => {
      const durationMs = Date.now() - startedAt;
      console.log(
        `[request] method=${req.method} path=${req.path} status=${res.statusCode} duration_ms=${durationMs}`
      );
    });

    next();
  });

  app.use((req, res, next) => {
    const startedAt = process.hrtime.bigint();

    res.on("finish", () => {
      const durationSeconds = Number(process.hrtime.bigint() - startedAt) / 1e9;
      metrics.observeRequest(req, res, durationSeconds);
    });

    next();
  });

  app.use(express.static(path.join(__dirname, "public")));

  app.get("/api/health", (_req, res) => {
    res.json({ status: "ok" });
  });

  app.get("/api/message", (_req, res) => {
    res.json({ message: "Scriptoria backend ready." });
  });

  app.get("/api/db/health", async (_req, res) => {
    try {
      const db = await dbHealthChecker();
      res.json({ ok: true, ...db });
    } catch (error) {
      res.status(503).json({
        ok: false,
        dbConnected: false,
        error: "db_unavailable",
        message: error.code === "ENOENT" ? "Database secret files are not mounted." : error.message
      });
    }
  });

  app.get("/api/notes", (_req, res) => {
    res.json({ notes: noteStore.list() });
  });

  app.post("/api/notes", (req, res) => {
    const text = typeof req.body?.text === "string" ? req.body.text.trim() : "";

    if (!text) {
      res.status(400).json({ error: "Note text is required." });
      return;
    }

    const note = noteStore.create(text.slice(0, 1000));
    console.log(`[note] action=create id=${note.id}`);
    res.status(201).json({ note });
  });

  app.delete("/api/notes/:id", (req, res) => {
    const deleted = noteStore.delete(req.params.id);

    if (!deleted) {
      res.status(404).json({ error: "Note not found." });
      return;
    }

    console.log(`[note] action=delete id=${req.params.id}`);
    res.status(204).end();
  });

  app.get("/api/debug/infra", (_req, res) => {
    res.json({
      projectName,
      environment,
      nodePort,
      requestPath: "Internet -> ALB -> EC2 host port -> Kubernetes Service -> Express Pod",
      timestamp: new Date().toISOString()
    });
  });

  app.get("/metrics", async (_req, res) => {
    res.set("Content-Type", metrics.registry.contentType);
    res.end(await metrics.registry.metrics());
  });

  app.post("/api/debug/inject-errors", (req, res) => {
    const count = Math.min(Math.max(Number(req.body?.count) || 50, 1), 5000);
    metrics.requestCounter.inc({ method: "GET", route: "/api/notes", status_code: "500" }, count);
    res.json({ injected: count, eta: "~3 minutes" });
  });

  app.get("*", (_req, res) => {
    res.sendFile(path.join(__dirname, "public", "index.html"));
  });

  return app;
}

function startServer() {
  const app = createApp();
  const port = Number(process.env.PORT || 3000);

  return app.listen(port, "0.0.0.0", () => {
    console.log(`Server listening on port ${port}`);
  });
}

if (require.main === module) {
  startServer();
}

module.exports = {
  createApp,
  createDbHealthChecker,
  createNoteStore,
  startServer
};
