[CmdletBinding()]
param(
    [string] $DscPath = (Get-Command dsc -ErrorAction Stop).Source,
    [string] $ResultPath
)

$ErrorActionPreference = "Stop"

trap {
    if ($ResultPath) {
        $_ | Out-String | Set-Content `
            -LiteralPath $ResultPath `
            -Encoding UTF8
    }

    break
}

function Test-Administrator {
    $identity = [Security.Principal.WindowsIdentity]::GetCurrent()
    $principal = [Security.Principal.WindowsPrincipal]::new($identity)

    return $principal.IsInRole(
        [Security.Principal.WindowsBuiltInRole]::Administrator
    )
}

function Get-RegistryValueOrNull {
    param(
        [Parameter(Mandatory)]
        [string] $Path,

        [Parameter(Mandatory)]
        [string] $Name
    )

    if (-not (Test-Path -LiteralPath $Path)) {
        return $null
    }

    $key = Get-Item -LiteralPath $Path

    return $key.GetValue(
        $Name,
        $null,
        [Microsoft.Win32.RegistryValueOptions]::DoNotExpandEnvironmentNames
    )
}

if (-not (Test-Administrator)) {
    $powershell = (Get-Process -Id $PID).Path
    $resultPath = Join-Path `
        $env:TEMP `
        "dotfiles-privacy-$([guid]::NewGuid().ToString('N')).log"
    $arguments = @(
        "-NoProfile"
        "-ExecutionPolicy"
        "Bypass"
        "-File"
        ('"{0}"' -f $PSCommandPath)
        "-DscPath"
        ('"{0}"' -f $DscPath)
        "-ResultPath"
        ('"{0}"' -f $resultPath)
    )

    try {
        $process = Start-Process `
            -FilePath $powershell `
            -ArgumentList $arguments `
            -Verb RunAs `
            -Wait `
            -PassThru

        if ($process.ExitCode -ne 0) {
            $details = if (Test-Path -LiteralPath $resultPath) {
                Get-Content -Raw -LiteralPath $resultPath
            }
            else {
                "No detailed error was returned by the elevated process."
            }

            throw "Elevated privacy settings failed with exit code $($process.ExitCode).`n$details"
        }
    }
    finally {
        Remove-Item `
            -LiteralPath $resultPath `
            -Force `
            -ErrorAction SilentlyContinue
    }

    return
}

$configurations = @(
    @{
        Name = "user privacy settings"
        Path = Join-Path $PSScriptRoot "configuration.dsc.yaml"
    }
    @{
        Name = "machine-wide privacy settings"
        Path = Join-Path $PSScriptRoot "machine.dsc.yaml"
    }
)

foreach ($configuration in $configurations) {
    & $DscPath config set --file $configuration.Path

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to apply $($configuration.Name)."
    }
}

$searchConfiguration = Get-Content `
    -Raw `
    -LiteralPath (Join-Path $PSScriptRoot "enhanced-search.json") |
    ConvertFrom-Json
$searchKey = $searchConfiguration.keyPath -replace '^HKLM\\', 'HKLM:\'
$searchValueName = $searchConfiguration.valueName
$enhancedSearch = Get-RegistryValueOrNull `
    -Path $searchKey `
    -Name $searchValueName

if ($enhancedSearch -ne $searchConfiguration.valueData) {
    $taskName = "Dotfiles-EnhancedSearch-$([guid]::NewGuid().ToString('N'))"
    $reg = Join-Path $env:SystemRoot "System32\reg.exe"
    $regArguments = 'add "{0}" /v "{1}" /t {2} /d {3} /f' -f @(
        $searchConfiguration.keyPath
        $searchConfiguration.valueName
        $searchConfiguration.valueType
        $searchConfiguration.valueData
    )
    $action = New-ScheduledTaskAction `
        -Execute $reg `
        -Argument $regArguments
    $principal = New-ScheduledTaskPrincipal `
        -UserId "SYSTEM" `
        -LogonType ServiceAccount `
        -RunLevel Highest
    $taskDefinition = New-ScheduledTask `
        -Action $action `
        -Principal $principal
    $startedAt = Get-Date

    try {
        Register-ScheduledTask `
            -TaskName $taskName `
            -InputObject $taskDefinition `
            -Force | Out-Null

        Start-ScheduledTask -TaskName $taskName

        $deadline = (Get-Date).AddSeconds(30)

        do {
            Start-Sleep -Milliseconds 200
            $task = Get-ScheduledTask -TaskName $taskName
            $taskInfo = Get-ScheduledTaskInfo -TaskName $taskName
            $hasRun = $taskInfo.LastRunTime -ge $startedAt.AddSeconds(-1)
        } while (
            (Get-Date) -lt $deadline -and
            (-not $hasRun -or $task.State -eq "Running")
        )

        if (-not $hasRun -or $task.State -eq "Running") {
            throw "Timed out while enabling enhanced file search."
        }

        if ($taskInfo.LastTaskResult -ne 0) {
            throw "Failed to enable enhanced file search (task result $($taskInfo.LastTaskResult))."
        }
    }
    finally {
        if (Get-ScheduledTask -TaskName $taskName -ErrorAction SilentlyContinue) {
            Unregister-ScheduledTask -TaskName $taskName -Confirm:$false
        }
    }
}

$enhancedSearch = Get-RegistryValueOrNull `
    -Path $searchKey `
    -Name $searchValueName

if ($enhancedSearch -ne $searchConfiguration.valueData) {
    throw "Failed to verify enhanced file search."
}
