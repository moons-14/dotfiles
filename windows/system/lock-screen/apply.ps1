$ErrorActionPreference = "Stop"

function Wait-WinRtOperation {
    param(
        [Parameter(Mandatory)]
        [object] $Operation,

        [Parameter(Mandatory)]
        [type] $ResultType
    )

    $asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() |
        Where-Object {
            $_.Name -eq "AsTask" -and
            $_.IsGenericMethod -and
            $_.GetParameters().Count -eq 1 -and
            $_.GetParameters()[0].ParameterType.Name -eq "IAsyncOperation``1"
        } |
        Select-Object -First 1

    if (-not $asTask) {
        throw "The WinRT AsTask adapter was not found."
    }

    $task = $asTask.MakeGenericMethod($ResultType).Invoke($null, @($Operation))
    return $task.GetAwaiter().GetResult()
}

function Wait-WinRtAction {
    param(
        [Parameter(Mandatory)]
        [object] $Action
    )

    $asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() |
        Where-Object {
            $_.Name -eq "AsTask" -and
            -not $_.IsGenericMethod -and
            $_.GetParameters().Count -eq 1 -and
            $_.GetParameters()[0].ParameterType.Name -eq "IAsyncAction"
        } |
        Select-Object -First 1

    if (-not $asTask) {
        throw "The WinRT action adapter was not found."
    }

    $task = $asTask.Invoke($null, @($Action))
    $task.GetAwaiter().GetResult()
}

Add-Type -AssemblyName System.Runtime.WindowsRuntime
[Windows.Storage.StorageFile, Windows.Storage, ContentType = WindowsRuntime] |
    Out-Null
[Windows.System.UserProfile.LockScreen, Windows.System.UserProfile, ContentType = WindowsRuntime] |
    Out-Null

$imagePath = Join-Path $env:SystemRoot "Web\Screen\img100.jpg"

if (-not (Test-Path -LiteralPath $imagePath -PathType Leaf)) {
    throw "The default Windows lock screen image was not found: $imagePath"
}

$currentImage = [Windows.System.UserProfile.LockScreen]::OriginalImageFile
$currentPath = if ($currentImage) {
    $currentImage.AbsolutePath.Replace("/", "\")
}

if ($currentPath -ieq $imagePath) {
    return
}

$file = Wait-WinRtOperation `
    -Operation ([Windows.Storage.StorageFile]::GetFileFromPathAsync($imagePath)) `
    -ResultType ([Windows.Storage.StorageFile])

Wait-WinRtAction `
    -Action ([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($file))

$updatedPath = [Windows.System.UserProfile.LockScreen]::OriginalImageFile.AbsolutePath.Replace(
    "/",
    "\"
)

if ($updatedPath -ine $imagePath) {
    throw "Windows did not accept the default lock screen image."
}
