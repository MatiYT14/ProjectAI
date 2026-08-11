$ErrorActionPreference = 'Stop'
Set-Location 'C:\ProjectAI'
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { throw 'Install Ollama first: https://ollama.com' }
Write-Host 'ProjectAI is ready. Example:' -ForegroundColor Cyan
Write-Host '  python .\projectai.py "Stwórz obby z checkpointami i systemem monet"'
python .\projectai.py
