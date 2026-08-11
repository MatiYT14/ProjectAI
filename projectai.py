"""ProjectAI: a local, test-first Roblox/Luau coding agent.

The agent can use Ollama locally. It never overwrites the live workspace by
default: each task is written to a versioned run directory and validated.
"""
from __future__ import annotations
import argparse, json, re, sys, time, urllib.request
from pathlib import Path

ROOT = Path(__file__).resolve().parent
CFG = json.loads((ROOT / "config/settings.json").read_text(encoding="utf-8"))
WORKSPACE = Path(CFG["workspace"])
MEMORY = Path(CFG["memory_file"])

SYSTEM = """You are ProjectAI, a senior Roblox/Luau developer. Work in small,
testable increments. Return ONLY valid JSON with this shape:
{"summary":"...","files":[{"path":"relative/path.lua","content":"..."}],"tests":["..."],"lessons":["..."]}
Never use absolute paths, never access secrets, and never put code outside the
requested workspace. Prefer ModuleScripts, clear names, server/client safety,
and explain assumptions in summary."""

def ask_ollama(prompt: str) -> dict:
    body = json.dumps({"model": CFG["model"], "stream": False,
                       "messages": [{"role":"system", "content": SYSTEM},
                                    {"role":"user", "content": prompt}]})
    req = urllib.request.Request(CFG["ollama_url"], data=body.encode(),
                                 headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=600) as response:
        result = json.loads(response.read().decode())
    text = result["message"]["content"].strip()
    match = re.search(r"\{.*\}", text, re.S)
    if not match:
        raise ValueError("Model did not return JSON")
    return json.loads(match.group(0))

def safe_path(relative: str) -> Path:
    p = Path(relative)
    if p.is_absolute() or ".." in p.parts or p.suffix.lower() not in {".lua", ".luau", ".md", ".json"}:
        raise ValueError(f"Unsafe output path: {relative}")
    return p

def validate(files: list[dict]) -> list[str]:
    errors = []
    for item in files:
        try: safe_path(item["path"])
        except Exception as e: errors.append(str(e)); continue
        code = item.get("content", "")
        if "loadstring(" in code or "HttpGet(" in code:
            errors.append(f"{item['path']}: blocked dynamic code/network primitive")
    return errors

def remember(task: str, result: dict, errors: list[str]) -> None:
    MEMORY.parent.mkdir(parents=True, exist_ok=True)
    record = {"time": time.strftime("%Y-%m-%dT%H:%M:%S"), "task": task,
              "summary": result.get("summary", ""), "lessons": result.get("lessons", []),
              "validation_errors": errors}
    with MEMORY.open("a", encoding="utf-8") as f: f.write(json.dumps(record, ensure_ascii=False)+"\n")

def recent_memory() -> str:
    if not MEMORY.exists(): return "No previous experience."
    lines = MEMORY.read_text(encoding="utf-8").splitlines()[-8:]
    return "\n".join(lines)

def push_to_studio(out: Path) -> None:
    commands = []
    for file in out.rglob("*.lua"):
        commands.append({"op": "write_script", "path": file.relative_to(out).as_posix(), "source": file.read_text(encoding="utf-8")})
    body = json.dumps({"commands": commands}).encode()
    req = urllib.request.Request("http://127.0.0.1:8765/enqueue", data=body, headers={"Content-Type": "application/json"})
    with urllib.request.urlopen(req, timeout=5) as response: reply = json.loads(response.read().decode())
    print(f"[ProjectAI] queued {reply.get('queued', 0)} Studio changes. Click the ProjectAI plugin button in Studio.")

def run(task: str, studio: bool = False) -> int:
    WORKSPACE.mkdir(parents=True, exist_ok=True)
    prompt = f"Task:\n{task}\n\nRecent project memory:\n{recent_memory()}"
    last = None
    for attempt in range(CFG["max_revisions"] + 1):
        phase = "generating an initial solution" if attempt == 0 else f"revising solution ({attempt}/{CFG['max_revisions']})"
        print(f"[ProjectAI] {phase}...", flush=True)
        try: result = ask_ollama(prompt if last is None else prompt + f"\n\nPrevious result had errors: {last}. Fix them.")
        except Exception as e:
            print(f"Model error: {e}\nIs Ollama running with model '{CFG['model']}'?", file=sys.stderr); return 2
        print(f"[ProjectAI] received {len(result.get('files', []))} files; validating...", flush=True)
        errors = validate(result.get("files", [])); remember(task, result, errors)
        if errors:
            last = "; ".join(errors); print(f"Revision {attempt+1}: {last}")
            continue
        stamp = time.strftime("%Y%m%d-%H%M%S")
        out = WORKSPACE / f"run-{stamp}"
        for item in result.get("files", []):
            dest = out / safe_path(item["path"]); dest.parent.mkdir(parents=True, exist_ok=True)
            dest.write_text(item.get("content", ""), encoding="utf-8")
        (out / "TASK.md").write_text(result.get("summary", task), encoding="utf-8")
        print(f"Created {len(result.get('files', []))} files in {out}")
        print(result.get("summary", "Done"))
        if studio: push_to_studio(out)
        else: print("Review the run, then use --studio to queue it for Roblox Studio.")
        return 0
    print("No validated result was produced.", file=sys.stderr); return 1

def main() -> None:
    ap = argparse.ArgumentParser(description="Local self-improving Roblox/Luau agent")
    ap.add_argument("--studio", action="store_true", help="queue generated scripts for the Studio bridge")
    ap.add_argument("task", nargs="*", help="what to build")
    args = ap.parse_args()
    task = " ".join(args.task) or input("ProjectAI task> ")
    raise SystemExit(run(task, args.studio))

if __name__ == "__main__": main()
