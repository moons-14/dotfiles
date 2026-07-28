$ErrorActionPreference = "Stop"

$source = Join-Path $PSScriptRoot "gitconfig"
$target = Join-Path $HOME ".gitconfig"

Copy-Item $source $target -Force
