$ErrorActionPreference = "Stop"

if (-not ("WindowsPowerMode.NativeMethods" -as [type])) {
    Add-Type -TypeDefinition @"
using System;
using System.Runtime.InteropServices;

namespace WindowsPowerMode
{
    public static class NativeMethods
    {
        [DllImport("powrprof.dll")]
        public static extern uint PowerSetUserConfiguredACPowerMode(
            ref Guid powerModeGuid);

        [DllImport("powrprof.dll")]
        public static extern uint PowerSetUserConfiguredDCPowerMode(
            ref Guid powerModeGuid);

        [DllImport("powrprof.dll")]
        public static extern uint PowerGetUserConfiguredACPowerMode(
            out Guid powerModeGuid);

        [DllImport("powrprof.dll")]
        public static extern uint PowerGetUserConfiguredDCPowerMode(
            out Guid powerModeGuid);
    }
}
"@
}

function Assert-Win32Success {
    param(
        [Parameter(Mandatory)]
        [uint32] $Result,

        [Parameter(Mandatory)]
        [string] $Operation
    )

    if ($Result -ne 0) {
        $message = [ComponentModel.Win32Exception]::new([int] $Result).Message
        throw "$Operation failed: $message (error $Result)."
    }
}

function Invoke-PowerCfg {
    param(
        [Parameter(Mandatory)]
        [string[]] $Arguments
    )

    & $script:powerCfg @Arguments | Out-Null

    if ($LASTEXITCODE -ne 0) {
        throw "powercfg $($Arguments -join ' ') failed with exit code $LASTEXITCODE."
    }
}

$bestPerformance = [guid] "ded574b5-45a0-4f42-8737-46345c09c238"

$result = [WindowsPowerMode.NativeMethods]::PowerSetUserConfiguredACPowerMode(
    [ref] $bestPerformance
)
Assert-Win32Success $result "Setting the AC power mode"

$result = [WindowsPowerMode.NativeMethods]::PowerSetUserConfiguredDCPowerMode(
    [ref] $bestPerformance
)
Assert-Win32Success $result "Setting the DC power mode"

$actualAcMode = [guid]::Empty
$result = [WindowsPowerMode.NativeMethods]::PowerGetUserConfiguredACPowerMode(
    [ref] $actualAcMode
)
Assert-Win32Success $result "Reading the AC power mode"

$actualDcMode = [guid]::Empty
$result = [WindowsPowerMode.NativeMethods]::PowerGetUserConfiguredDCPowerMode(
    [ref] $actualDcMode
)
Assert-Win32Success $result "Reading the DC power mode"

if ($actualAcMode -ne $bestPerformance -or $actualDcMode -ne $bestPerformance) {
    throw "Windows did not retain Best performance for both AC and DC power."
}

$script:powerCfg = Join-Path $env:SystemRoot "System32\powercfg.exe"
$energySaverSubgroup = "de830923-a562-41af-a086-e3a2c6bad2da"
$energySaverThreshold = "e69653ca-cf7f-4f05-aa73-cb833fa90ad4"
$guidPattern = "[0-9a-fA-F]{8}(?:-[0-9a-fA-F]{4}){3}-[0-9a-fA-F]{12}"

$activeSchemeOutput = & $script:powerCfg /getactivescheme
if ($LASTEXITCODE -ne 0) {
    throw "Failed to read the active power scheme."
}

$activeScheme = [regex]::Match(
    ($activeSchemeOutput -join [Environment]::NewLine),
    $guidPattern
).Value

if (-not $activeScheme) {
    throw "The active power scheme GUID could not be parsed."
}

$schemeOutput = & $script:powerCfg /list
if ($LASTEXITCODE -ne 0) {
    throw "Failed to enumerate power schemes."
}

$schemes = [regex]::Matches(
    ($schemeOutput -join [Environment]::NewLine),
    $guidPattern
).Value | Sort-Object -Unique

if (-not $schemes) {
    throw "No power schemes were found."
}

foreach ($scheme in $schemes) {
    Invoke-PowerCfg @(
        "/setacvalueindex"
        $scheme
        $energySaverSubgroup
        $energySaverThreshold
        "0"
    )
    Invoke-PowerCfg @(
        "/setdcvalueindex"
        $scheme
        $energySaverSubgroup
        $energySaverThreshold
        "0"
    )
}

Invoke-PowerCfg @("/setactive", $activeScheme)
