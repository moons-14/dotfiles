$ErrorActionPreference = "Stop"

function Test-ParsecInstalled {
    $candidatePaths = @(
        (Join-Path $env:ProgramFiles "Parsec\parsecd.exe")
        (Join-Path $env:LOCALAPPDATA "Parsec\parsecd.exe")
        (Join-Path $env:APPDATA "Parsec\parsecd.exe")
    )

    if (${env:ProgramFiles(x86)}) {
        $candidatePaths += Join-Path ${env:ProgramFiles(x86)} "Parsec\parsecd.exe"
    }

    if ($candidatePaths | Where-Object { Test-Path -LiteralPath $_ }) {
        return $true
    }

    $uninstallRoots = @(
        "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
        "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\*"
        "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\*"
    )

    foreach ($root in $uninstallRoots) {
        $installedPackage = Get-ItemProperty -Path $root -ErrorAction SilentlyContinue |
            Where-Object { $_.DisplayName -like "Parsec*" } |
            Select-Object -First 1

        if ($installedPackage) {
            return $true
        }
    }

    return $false
}

if (Test-ParsecInstalled) {
    Write-Host "Parsec is already installed."
    return
}

$declarationPath = Join-Path $PSScriptRoot "installer.json"
$declaration = Get-Content -LiteralPath $declarationPath -Raw | ConvertFrom-Json
$installerPath = Join-Path ([System.IO.Path]::GetTempPath()) (
    "parsec-{0}.exe" -f [guid]::NewGuid().ToString("N")
)

try {
    Write-Host "Downloading the declared Parsec installer..."
    Invoke-WebRequest -Uri $declaration.url -OutFile $installerPath -UseBasicParsing

    $actualHash = (Get-FileHash -LiteralPath $installerPath -Algorithm SHA256).Hash
    if ($actualHash -ne $declaration.sha256) {
        throw "Parsec installer SHA256 mismatch. Expected $($declaration.sha256), got $actualHash."
    }

    $version = (Get-Item -LiteralPath $installerPath).VersionInfo.FileVersion
    if ($version -ne $declaration.version) {
        throw "Parsec installer version mismatch. Expected $($declaration.version), got $version."
    }

    $signature = Get-AuthenticodeSignature -LiteralPath $installerPath
    if ($signature.Status -ne [System.Management.Automation.SignatureStatus]::Valid) {
        throw "Parsec installer signature is not valid: $($signature.StatusMessage)"
    }

    if ($signature.SignerCertificate.Subject -ne $declaration.signerSubject) {
        throw "Parsec installer signer subject does not match the declaration."
    }

    if ($signature.SignerCertificate.Thumbprint -ne $declaration.signerThumbprint) {
        throw "Parsec installer signer thumbprint does not match the declaration."
    }

    Write-Host "Installing verified Parsec $version for all users..."
    $process = Start-Process -FilePath $installerPath `
        -ArgumentList $declaration.silentArguments `
        -Verb RunAs `
        -Wait `
        -PassThru

    if ($process.ExitCode -notin @(0, 3010)) {
        throw "Parsec installer failed with exit code $($process.ExitCode)."
    }

    if (-not (Test-ParsecInstalled)) {
        throw "Parsec installer completed, but the installation could not be verified."
    }

    Write-Host "Parsec installation is present and verified."
}
finally {
    Remove-Item -LiteralPath $installerPath -Force -ErrorAction SilentlyContinue
}
