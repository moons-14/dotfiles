$ErrorActionPreference = "Stop"

$userDir = Join-Path $env:APPDATA "Code\User"
$runtimeDir = Join-Path $HOME ".vscode"

New-Item -ItemType Directory -Force -Path $userDir, $runtimeDir | Out-Null

Copy-Item (Join-Path $PSScriptRoot "settings.json") `
    (Join-Path $userDir "settings.json") -Force

Copy-Item (Join-Path $PSScriptRoot "argv.json") `
    (Join-Path $runtimeDir "argv.json") -Force

$codeCandidates = @(
    (Join-Path $env:LOCALAPPDATA "Programs\Microsoft VS Code\bin\code.cmd"),
    (Join-Path $env:ProgramFiles "Microsoft VS Code\bin\code.cmd")
)

$code = $codeCandidates | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $code) {
    $command = Get-Command code.cmd -ErrorAction SilentlyContinue
    if ($command) {
        $code = $command.Source
    }
}

if (-not $code) {
    throw "VS Code CLI was not found."
}

$installedExtensions = @(
    & $code --list-extensions |
        ForEach-Object { $_.Trim().ToLowerInvariant() }
)

Get-Content (Join-Path $PSScriptRoot "extensions.txt") |
    Where-Object { $_.Trim() -and -not $_.Trim().StartsWith("#") } |
    ForEach-Object {
        $extension = $_.Trim()

        if ($installedExtensions -notcontains $extension.ToLowerInvariant()) {
            & $code --install-extension $extension

            if ($LASTEXITCODE -ne 0) {
                throw "Failed to install VS Code extension: $extension"
            }
        }
    }

& $code --update-extensions
if ($LASTEXITCODE -ne 0) {
    throw "Failed to update VS Code extensions."
}
