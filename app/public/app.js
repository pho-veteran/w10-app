const notesListEl = document.getElementById("notes-list");
const emptyStateEl = document.getElementById("empty-state");
const noteCountEl = document.getElementById("note-count");
const noteFormEl = document.getElementById("note-form");
const noteTextEl = document.getElementById("note-text");
const formStatusEl = document.getElementById("form-status");
const noteTemplate = document.getElementById("note-template");
const debugToggleEl = document.getElementById("debug-toggle");
const debugPanelEl = document.getElementById("debug-panel");
const fireAlertBtnEl = document.getElementById("fire-alert-btn");
const injectCountEl = document.getElementById("inject-count");

let notes = [];
let debugLoaded = false;

function setStatus(message, tone = "neutral") {
  formStatusEl.textContent = message;
  formStatusEl.dataset.tone = tone;
}

function formatTime(value) {
  return new Intl.DateTimeFormat(undefined, {
    dateStyle: "medium",
    timeStyle: "short"
  }).format(new Date(value));
}

function renderNotes() {
  notesListEl.textContent = "";
  noteCountEl.textContent = String(notes.length);
  emptyStateEl.hidden = notes.length > 0;

  for (const note of notes) {
    const item = noteTemplate.content.firstElementChild.cloneNode(true);
    const timeEl = item.querySelector(".note-time");
    const textEl = item.querySelector(".note-text");
    const deleteButton = item.querySelector(".note-delete");

    timeEl.dateTime = note.createdAt;
    timeEl.textContent = formatTime(note.createdAt);
    textEl.textContent = note.text;
    deleteButton.addEventListener("click", () => deleteNote(note.id));

    notesListEl.appendChild(item);
  }
}

async function requestJson(url, options) {
  const response = await fetch(url, options);

  if (!response.ok) {
    const payload = await response.json().catch(() => ({}));
    throw new Error(payload.error || `HTTP ${response.status}`);
  }

  if (response.status === 204) {
    return null;
  }

  return await response.json();
}

async function loadNotes() {
  try {
    const payload = await requestJson("/api/notes");
    notes = payload.notes || [];
    renderNotes();
    setStatus("Ledger ready.");
  } catch (error) {
    setStatus(`Could not read the ledger: ${error.message}`, "error");
  }
}

async function addNote(event) {
  event.preventDefault();

  const text = noteTextEl.value.trim();

  if (!text) {
    setStatus("Write something before sealing the note.", "error");
    noteTextEl.focus();
    return;
  }

  try {
    const payload = await requestJson("/api/notes", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ text })
    });

    notes = [payload.note, ...notes];
    noteTextEl.value = "";
    renderNotes();
    setStatus("Note sealed.", "success");
  } catch (error) {
    setStatus(`The scribe refused the note: ${error.message}`, "error");
  }
}

async function deleteNote(id) {
  try {
    await requestJson(`/api/notes/${encodeURIComponent(id)}`, { method: "DELETE" });
    notes = notes.filter((note) => note.id !== id);
    renderNotes();
    setStatus("Note burned.", "success");
  } catch (error) {
    setStatus(`Could not burn the note: ${error.message}`, "error");
  }
}

function setDebugField(id, value) {
  document.getElementById(id).textContent = value || "-";
}

async function loadDebugInfo() {
  const payload = await requestJson("/api/debug/infra");

  setDebugField("debug-project", payload.projectName);
  setDebugField("debug-environment", payload.environment);
  setDebugField("debug-node-port", payload.nodePort);
  setDebugField("debug-request-path", payload.requestPath);
  setDebugField("debug-timestamp", payload.timestamp);
  debugLoaded = true;
}

async function toggleDebugPanel() {
  const shouldShow = debugPanelEl.hidden;
  debugPanelEl.hidden = !shouldShow;
  debugToggleEl.setAttribute("aria-expanded", String(shouldShow));

  if (shouldShow && !debugLoaded) {
    try {
      await loadDebugInfo();
    } catch (error) {
      setDebugField("debug-request-path", `Debug failed: ${error.message}`);
    }
  }
}

async function fireAlert() {
  const count = Number(injectCountEl.value);
  fireAlertBtnEl.disabled = true;
  setDebugField("debug-alert-status", "Injecting errors…");
  try {
    const payload = await requestJson("/api/debug/inject-errors", {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ count })
    });
    setDebugField("debug-alert-status", `${payload.injected} errors injected — alert fires in ${payload.eta}`);
  } catch (error) {
    setDebugField("debug-alert-status", `Failed: ${error.message}`);
  } finally {
    fireAlertBtnEl.disabled = false;
  }
}

noteFormEl.addEventListener("submit", addNote);
debugToggleEl.addEventListener("click", toggleDebugPanel);
fireAlertBtnEl.addEventListener("click", fireAlert);
loadNotes();
