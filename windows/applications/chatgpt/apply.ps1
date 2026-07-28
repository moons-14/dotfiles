$ErrorActionPreference = "Stop"

winget install `
    --id 9PLM9XGG6VKS `
    --source msstore `
    --accept-package-agreements `
    --accept-source-agreements `
    --silent `
    --disable-interactivity

if ($LASTEXITCODE -ne 0) {
    throw "Failed to install or update ChatGPT."
}
