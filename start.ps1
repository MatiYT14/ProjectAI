$ErrorActionPreference = 'Stop'
Set-Location 'C:\ProjectAI'
if (-not (Get-Command ollama -ErrorAction SilentlyContinue)) { throw 'Install Ollama first: https://ollama.com' }
Write-Host 'ProjectAI is ready. Example:' -ForegroundColor Cyan
Write-Host '  python .\projectai.py "Create an obby with checkpoints and a coin system"'
python .\projectai.py
