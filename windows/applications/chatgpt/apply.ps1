$ErrorActionPreference = "Stop"

winget install `
    --id 9PLM9XGG6VKS `
    --source msstore `
    --accept-package-agreements `
    --accept-source-agreements `
    --silent `
    --disable-interactivity

$exitCode = $LASTEXITCODE
$updateNotApplicable = -1978335189 # 0x8A15002B

if ($exitCode -notin @(0, $updateNotApplicable)) {
    throw "Failed to install or update ChatGPT (WinGet exit code $exitCode)."
}
