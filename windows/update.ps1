$ErrorActionPreference = "Stop"

Push-Location $PSScriptRoot

try {
    scoop update
    scoop import .\Scoopfile.json
    scoop update *

    dsc config set --file .\configuration.dsc.yaml

    & .\applications\chatgpt\apply.ps1
    & .\applications\git\apply.ps1
    & .\applications\vscode\apply.ps1
    & .\system\wallpaper\apply.ps1
}
finally {
    Pop-Location
}
