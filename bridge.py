"""Small local MCP-compatible bridge for the ProjectAI Roblox Studio plugin."""
from __future__ import annotations
import json, subprocess, sys, threading, time
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOST, PORT = "127.0.0.1", 8765
queue: list[dict] = []
results: list[dict] = []
logs: list[str] = []
active = None
lock = threading.Lock()

def log(line: str):
    with lock:
        logs.append(line.rstrip()[:500])
        del logs[:-80]

def run_agent(task: str):
    global active
    log("Agent: starting task")
    proc = subprocess.Popen([sys.executable, "C:/ProjectAI/projectai.py", "--studio", task], stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)
    with lock: active = proc
    for line in proc.stdout or []: log(line)
    code = proc.wait(); log(f"Agent: finished with exit code {code}")
    with lock: active = None

class Handler(BaseHTTPRequestHandler):
    def log_message(self, *_): pass
    def send_json(self, code: int, data: dict):
        raw = json.dumps(data).encode()
        self.send_response(code); self.send_header("Content-Type", "application/json")
        self.send_header("Content-Length", str(len(raw))); self.end_headers(); self.wfile.write(raw)
    def body(self):
        n = int(self.headers.get("Content-Length", 0)); return json.loads(self.rfile.read(n) or b"{}")
    def do_GET(self):
        if self.path == "/health": self.send_json(200, {"ok": True, "service": "ProjectAI-MCP", "queued": len(queue)}); return
        if self.path.startswith("/poll"):
            with lock: item = queue.pop(0) if queue else None
            self.send_json(200, {"command": item}); return
        if self.path == "/status":
            with lock: self.send_json(200, {"running": active is not None, "logs": list(logs), "queued": len(queue)}); return
        self.send_json(404, {"error": "not found"})
    def do_POST(self):
        if self.path == "/enqueue":
            data = self.body(); items = data.get("commands", [])
            with lock: queue.extend(items)
            self.send_json(200, {"ok": True, "queued": len(items)}); return
        if self.path == "/task":
            task = str(self.body().get("task", "")).strip()
            if not task: self.send_json(400, {"error": "task is empty"}); return
            with lock:
                if active is not None: self.send_json(409, {"error": "agent is already running"}); return
            threading.Thread(target=run_agent, args=(task,), daemon=True).start()
            self.send_json(202, {"ok": True}); return
        if self.path == "/result":
            with lock: results.append(self.body())
            self.send_json(200, {"ok": True}); return
        if self.path == "/mcp":
            req = self.body(); method = req.get("method")
            if method == "initialize": out = {"protocolVersion": "2024-11-05", "capabilities": {"tools": {}}, "serverInfo": {"name": "ProjectAI-MCP", "version": "1.0.0"}}
            elif method == "tools/list": out = {"tools": [{"name": "studio_write_script", "description": "Write a Script, LocalScript, or ModuleScript in Roblox Studio", "inputSchema": {"type": "object", "properties": {"path": {"type": "string"}, "source": {"type": "string"}}, "required": ["path", "source"]}}]}
            elif method == "tools/call":
                args = req.get("params", {}).get("arguments", {}); cmd = {"op": "write_script", **args}
                with lock: queue.append(cmd)
                out = {"content": [{"type": "text", "text": "Queued for Roblox Studio"}]}
            else: out = {}
            self.send_json(200, {"jsonrpc": "2.0", "id": req.get("id"), "result": out}); return
        self.send_json(404, {"error": "not found"})

if __name__ == "__main__":
    print(f"ProjectAI MCP bridge listening on http://{HOST}:{PORT}")
    ThreadingHTTPServer((HOST, PORT), Handler).serve_forever()
