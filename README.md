# ProjectAI

Local AI agent for building Roblox/Luau projects.

## Start

1. Install Python 3.10+ and Ollama.
2. The `qwen2.5-coder:14b` model is already configured.
3. Run `powershell -ExecutionPolicy Bypass -File C:\ProjectAI\start.ps1`.
4. Enter a task such as `Create an obby with checkpoints, coins, and a shop`.

Results are written to `sandbox/run-*`. The agent keeps project experience in
`memory/experiences.jsonl`, performs revisions, and does not overwrite live
projects by default.

## MCP bridge for Roblox Studio

Run in a second PowerShell window:

```powershell
powershell -ExecutionPolicy Bypass -File C:\ProjectAI\start-bridge.ps1
```

Install `RobloxStudioProjectAI.lua` as a Studio plugin and allow the plugin to
connect to localhost when prompted. Then run:

```powershell
python C:\ProjectAI\projectai.py --studio "Create a checkpoint and coin system"
```

Clicking the ProjectAI toolbar button applies queued scripts to the correct
services. Each change creates a Change History waypoint, so it can be undone.
The bridge listens on localhost only.

## GitHub-hosted plugin

`plugin/Bootstrapper.lua` is the small script intended for the one-time Roblox
plugin publication. It downloads `plugin/version.json` and the current
`plugin/Main.lua` from GitHub at startup. Update the runtime in GitHub without
republishing the bootstrapper. The first run may ask Studio for permission to
communicate with `raw.githubusercontent.com`.
