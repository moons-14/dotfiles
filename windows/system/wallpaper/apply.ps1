$ErrorActionPreference = "Stop"

$wallpaperDir = Join-Path $HOME ".wallpaper"

if (Test-Path (Join-Path $wallpaperDir ".git")) {
    git -C $wallpaperDir pull --ff-only
}
elseif (-not (Test-Path $wallpaperDir)) {
    git clone https://github.com/moons-14/wallpapers.git $wallpaperDir
}
else {
    throw "$wallpaperDir exists but is not a Git repository."
}

if ($LASTEXITCODE -ne 0) {
    throw "Failed to synchronize the wallpaper repository."
}

$themeDir = Join-Path $env:LOCALAPPDATA "Microsoft\Windows\Themes"
$themeTarget = Join-Path $themeDir "moons-wallpaper.theme"

New-Item -ItemType Directory -Force -Path $themeDir | Out-Null
Copy-Item (Join-Path $PSScriptRoot "wallpaper.theme") $themeTarget -Force

$currentTheme = (Get-ItemProperty `
    "HKCU:\Software\Microsoft\Windows\CurrentVersion\Themes" `
    -Name CurrentTheme `
    -ErrorAction SilentlyContinue).CurrentTheme

if ($currentTheme -ne $themeTarget) {
    Start-Process $themeTarget
}
