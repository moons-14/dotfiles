[CmdletBinding()]
param(
    [string] $TargetUserSid = [Security.Principal.WindowsIdentity]::GetCurrent().User.Value
)

$ErrorActionPreference = "Stop"

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

if (-not (Test-Administrator)) {
    $powershell = (Get-Process -Id $PID).Path
    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        ('"{0}"' -f $PSCommandPath)
        "-TargetUserSid"
        $TargetUserSid
    )

    $process = Start-Process `
        -FilePath $powershell `
        -ArgumentList $arguments `
        -Verb RunAs `
        -Wait `
        -PassThru

    if ($process.ExitCode -ne 0) {
        throw "Elevated advanced settings failed with exit code $($process.ExitCode)."
    }

    return
}

$explorerPolicyKey = Join-Path `
    "Registry::HKEY_USERS\$TargetUserSid" `
    "Software\Policies\Microsoft\Windows\Explorer"

New-Item -Path $explorerPolicyKey -Force | Out-Null
New-ItemProperty `
    -Path $explorerPolicyKey `
    -Name "ShowRunAsDifferentUserInStart" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

$showRunAsDifferentUser = Get-ItemPropertyValue `
    -Path $explorerPolicyKey `
    -Name "ShowRunAsDifferentUserInStart"

if ($showRunAsDifferentUser -ne 1) {
    throw 'Failed to enable "Run as different user" in Start.'
}

$fileSystemKey = "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem"

New-ItemProperty `
    -Path $fileSystemKey `
    -Name "LongPathsEnabled" `
    -PropertyType DWord `
    -Value 1 `
    -Force | Out-Null

$longPathsEnabled = Get-ItemPropertyValue `
    -Path $fileSystemKey `
    -Name "LongPathsEnabled"

if ($longPathsEnabled -ne 1) {
    throw "Failed to enable Win32 long paths."
}
