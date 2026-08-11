# ProjectAI

Lokalny agent AI do tworzenia projektów Roblox/Luau.

## Start

1. Zainstaluj Python 3.10+ i Ollama.
2. Masz już pobrany model `qwen2.5-coder:14b`.
3. Uruchom: `powershell -ExecutionPolicy Bypass -File C:\ProjectAI\start.ps1`
4. Wpisz zadanie, np. `Stwórz obby z checkpointami, monetami i sklepem`.

Wyniki trafiają do `sandbox/run-...`. Agent ma pamięć doświadczeń w
`memory/experiences.jsonl`, wykonuje kilka rewizji i nie nadpisuje istniejących
projektów.

## Bridge MCP do Roblox Studio

Uruchom w drugim PowerShellu:

```powershell
powershell -ExecutionPolicy Bypass -File C:\ProjectAI\start-bridge.ps1
```

W Roblox Studio utwórz plugin z pliku `RobloxStudioProjectAI.lua` i włącz
`Game Settings > Security > Allow HTTP Requests`. Następnie generuj projekt z:

```powershell
python C:\ProjectAI\projectai.py --studio "Stwórz system checkpointów i monet"
```

Kliknięcie przycisku ProjectAI w toolbarze Studio pobierze kolejkę i wstawi
skrypty do właściwych usług. Każda zmiana tworzy waypoint w Change History,
więc można ją cofnąć. Bridge nasłuchuje wyłącznie na localhost.
