$ErrorActionPreference = 'Stop'
$source = 'C:\ProjectAI\RobloxStudioProjectAI.lua'
$targetDir = 'C:\Users\mateu\AppData\Local\Roblox\Plugins'
$target = Join-Path $targetDir 'ProjectAI.lua'
New-Item -ItemType Directory -Force -Path $targetDir | Out-Null
Copy-Item -LiteralPath $source -Destination $target -Force
Write-Host "ProjectAI plugin synced to $target"
