# Windows dotfiles

This directory contains the Windows-specific configuration for this dotfiles
repository.

The design has four layers:

1. **Native package declarations**
   - Scoop uses `Scoopfile.json`.
   - WinGet / Microsoft Store packages use DSC `Microsoft.WinGet/Package`.
2. **Windows desired state**
   - Windows settings use DSC resources grouped by settings domain.
3. **Application-owned configuration**
   - Each application that needs files or CLI-based configuration has its own
     directory and its own small `apply.ps1`.
4. **One root entry point**
   - `update.ps1` only invokes the native package/configuration systems and the
     application-specific apply scripts.

The root script intentionally contains no application-specific paths, registry
logic, wallpaper loop, or VS Code extension list.

## Layout

```text
windows/
├── README.md
├── update.ps1
├── Scoopfile.json
├── configuration.dsc.yaml
│
├── packages/
│   └── winget.dsc.yaml
│
├── system/
│   ├── taskbar.dsc.yaml
│   ├── personalization.dsc.yaml
│   ├── start.dsc.yaml
│   ├── device-usage.dsc.yaml
│   ├── explorer.dsc.yaml
│   ├── ime.dsc.yaml
│   ├── privacy/
│   │   ├── configuration.dsc.yaml
│   │   ├── machine.dsc.yaml
│   │   ├── enhanced-search.json
│   │   └── apply.ps1
│   ├── advanced-settings/
│   │   ├── configuration.dsc.yaml
│   │   └── apply.ps1
│   ├── lock-screen/
│   │   └── apply.ps1
│   ├── power/
│   │   └── apply.ps1
│   └── wallpaper/
│       ├── apply.ps1
│       └── wallpaper.theme
│
└── applications/
    ├── chatgpt/
    │   └── apply.ps1
    ├── git/
    │   ├── apply.ps1
    │   └── gitconfig
    │
    └── vscode/
        ├── apply.ps1
        ├── settings.json
        ├── argv.json
        └── extensions.txt
```

## Fresh Windows installation

Open a normal, non-elevated PowerShell window.

### 1. Allow local scripts

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### 2. Install Scoop and bootstrap Git

```powershell
Invoke-RestMethod https://get.scoop.sh | Invoke-Expression
scoop install git
```

### 3. Clone dotfiles

```powershell
git clone https://github.com/moons-14/dotfiles.git "$HOME\dotfiles"
Set-Location "$HOME\dotfiles\windows"
```

### 4. Install Microsoft DSC v3

```powershell
winget install --id 9NVTPZWRC6KQ --source msstore
```

If `dsc` is not available in the current shell immediately after installation,
open a new PowerShell window and return to:

```powershell
Set-Location "$HOME\dotfiles\windows"
```

### 5. Apply everything

```powershell
.\update.ps1
```

## Normal workflow

```powershell
Set-Location "$HOME\dotfiles\windows"

git pull
.\update.ps1
```

`update.ps1` stays intentionally small:

```powershell
scoop update
scoop import .\Scoopfile.json
scoop update *

dsc config set --file .\configuration.dsc.yaml

& .\applications\chatgpt\apply.ps1
& .\applications\git\apply.ps1
& .\applications\vscode\apply.ps1
& .\system\advanced-settings\apply.ps1
& .\system\lock-screen\apply.ps1
& .\system\power\apply.ps1
& .\system\privacy\apply.ps1
& .\system\wallpaper\apply.ps1
```

The specialized scripts own the details of their own configuration. The
advanced-settings and privacy scripts request elevation for protected policies
and machine-wide settings. Scoop, DSC user settings, and application
configuration stay in the normal user process.

## Packages

### Scoop

`Scoopfile.json` currently declares:

- Git

The update entry point:

1. updates Scoop and bucket metadata
2. imports `Scoopfile.json` so newly declared packages are installed
3. updates all applications installed through Scoop

### WinGet / Microsoft Store

`packages/winget.dsc.yaml` manages:

- Google Chrome
- 1Password
- Visual Studio Code
- Vesktop (`Vencord.Vesktop`)
- Moonlight (`MoonlightGameStreamingProject.Moonlight`)
- 7-Zip

ChatGPT is intentionally not part of this DSC file because its Microsoft Store
installation requires explicit package/source agreement acceptance.

### ChatGPT

`applications/chatgpt/apply.ps1` uses OpenAI's documented WinGet installation:

```powershell
winget install `
    --id 9PLM9XGG6VKS `
    --source msstore `
    --accept-package-agreements `
    --accept-source-agreements `
    --silent `
    --disable-interactivity
```

The Store product ID `9PLM9XGG6VKS` is the ChatGPT Windows app managed here.
ChatGPT Classic (`9NT1R1C2HH7J`) is intentionally not installed.
WinGet's `APPINSTALLER_CLI_ERROR_UPDATE_NOT_APPLICABLE` result is treated as
success because it means the installed ChatGPT version is already current.

7-Zip is intentionally installed with its normal Windows installer through
WinGet rather than as a portable Scoop package, because the normal installer
provides Explorer shell integration.

## Windows settings

### Personalization

`system/personalization.dsc.yaml` configures:

- automatic accent color
- dark Windows and app modes
- picture mode for the lock screen
- lock-screen facts and tips: off
- automatic lock-screen status selection: off

`system/lock-screen/apply.ps1` uses the Windows LockScreen API to select the
built-in `%SystemRoot%\Web\Screen\img100.jpg` image. The script first checks the
current image and only calls the API when the image differs.

### Start

`system/start.dsc.yaml` configures:

- recently added apps: on
- recommended and recent files: off
- recommendations for tips, shortcuts, and new apps: off
- app-launch tracking and most-used app personalization: off

### Device usage

`system/device-usage.dsc.yaml` explicitly clears both `Intent` and `Priority`
for Development, Gaming, Family, Creativity, School, Entertainment, and
Business.

### Privacy, diagnostics, feedback, and search

`system/privacy/configuration.dsc.yaml` configures user-scoped preferences:

- advertising ID: off
- website access to the language list: off
- personalized offers and tailored experiences: off
- Windows Spotlight, third-party content, Settings suggestions, tips, welcome
  experiences, device-setup suggestions, and suggested app installation: off
- File Explorer sync-provider promotions: off
- inking and typing diagnostics: off
- feedback frequency and prompts: never
- device search history and search highlights: off

`system/privacy/apply.ps1` requests elevation and applies both the user-scoped
configuration above and `system/privacy/machine.dsc.yaml`, which configures:

- advertising ID and Windows consumer experiences: off by policy
- diagnostic data: the lowest level supported by the installed Windows edition
- feedback notifications and Diagnostic Data Viewer: off
- diagnostic log and dump collection: limited
- publishing and uploading activity history: off

The protected Windows Search key doesn't grant write access to administrators,
so `apply.ps1` applies the desired value from the declarative
`enhanced-search.json` as `SYSTEM` to set Find my files to Enhanced. It uses a
uniquely named one-shot Scheduled Task and always unregisters it immediately
afterward. It doesn't change the key's owner or access-control list and doesn't
leave a persistent task behind.

Windows Pro still sends required diagnostic data even when `AllowTelemetry` is
set to the Security value (`0`); only editions that support the Security level
honor diagnostic data completely off. The configuration nevertheless disables
optional diagnostic data and every related user-facing toggle. Enhanced search
indexes the full user profile, so its initial indexing can temporarily use more
CPU, battery, and storage.

### Taskbar

`system/taskbar.dsc.yaml` configures:

- Widgets: off
- Resume: off
- Search: icon only
- Alignment: left

### Explorer

`system/explorer.dsc.yaml` configures:

- show known file extensions
- show hidden files and protected operating-system files
- show the full path in the title bar
- show empty drives

7-Zip context-menu integration is left to the official 7-Zip installer. No
unsupported Explorer context-menu patches are applied.

### Microsoft IME

`system/ime.dsc.yaml` configures:

- Muhenkan: IME Off
- Henkan: IME On

### Advanced settings and clipboard

`system/advanced-settings/configuration.dsc.yaml` configures:

- End task from the taskbar: on
- clipboard history: on

`system/advanced-settings/apply.ps1` additionally configures:

- "Run as different user" in Start: on
- Win32 long paths: on

The long-path setting is machine-wide. The script enables "Run as different
user" through the protected per-user policy key, passes the original user's SID
through UAC, writes both settings to the intended hives, and verifies their
values. A restart is recommended after changing long-path support because a
process can cache the setting after its first affected file call.

### Power

`system/power/apply.ps1` uses the Windows 11 power-mode API to select Best
performance independently for both AC and battery power. It verifies both
configured modes, then sets the automatic Energy Saver threshold to zero on
every installed power scheme.

## Git

Git's user configuration lives in:

```text
applications/git/gitconfig
```

It currently contains:

```ini
[user]
    name = moons-14
    email = moons@moons14.com
[core]
    sshCommand = C:/Windows/System32/OpenSSH/ssh.exe
```

`applications/git/apply.ps1` copies this file to:

```text
%USERPROFILE%\.gitconfig
```

This means the repository is the source of truth for the managed global Git
configuration. Add future Git settings to `applications/git/gitconfig`, not to
`update.ps1`.

## Visual Studio Code

VS Code configuration lives entirely under:

```text
applications/vscode/
```

### `settings.json`

Minimal editor defaults:

- no startup welcome editor
- format on save
- final newline

### `argv.json`

Sets the VS Code UI locale to Japanese:

```json
{
  "locale": "ja"
}
```

### `extensions.txt`

One Marketplace extension ID per line.

Currently:

```text
MS-CEINTL.vscode-language-pack-ja
```

`applications/vscode/apply.ps1` copies the config files and uses the official
VS Code CLI. It first checks `code --list-extensions`, installs only missing
declared extensions, then runs `code --update-extensions`.

To add another extension, only edit `extensions.txt`.

## Wallpaper

Wallpaper management lives under:

```text
system/wallpaper/
```

`apply.ps1` synchronizes:

```text
https://github.com/moons-14/wallpapers
```

to:

```text
%USERPROFILE%\.wallpaper
```

The slideshow itself is not implemented in PowerShell.

`wallpaper.theme` uses the native Windows slideshow mechanism:

```ini
[Slideshow]
Interval=60000
Shuffle=1
ImagesRootPath=%USERPROFILE%\.wallpaper
```

Windows therefore performs the one-minute randomized rotation. The script only
keeps the Git repository and theme declaration synchronized.

The theme also contains the required Windows theme validity marker:

```ini
[MasterThemeSelector]
MTSM=DABJDKT
```

Without this section, Windows rejects the `.theme` file instead of applying it.

## Adding an application

### Package only

If it belongs in Scoop `main`, add it to:

```text
Scoopfile.json
```

Otherwise add a `Microsoft.WinGet/Package` resource to:

```text
packages/winget.dsc.yaml
```

No PowerShell file is necessary when installation is the only requirement.

### Package with configuration

If an application needs managed files or its own CLI, create:

```text
applications/<name>/
├── apply.ps1
└── <native configuration files>
```

Then add only one call to the root `update.ps1`:

```powershell
& .\applications\<name>\apply.ps1
```

Keep all application-specific logic inside that directory.

## Adding a Windows setting

Settings that can be represented as DSC belong under `system/` and should be
grouped by responsibility:

```text
system/taskbar.dsc.yaml
system/personalization.dsc.yaml
system/start.dsc.yaml
system/device-usage.dsc.yaml
system/explorer.dsc.yaml
system/ime.dsc.yaml
system/privacy/configuration.dsc.yaml
system/privacy/machine.dsc.yaml
system/advanced-settings/configuration.dsc.yaml
```

Include ordinary user-scoped DSC documents from the root
`configuration.dsc.yaml`. A protected or machine-wide document may instead be
applied by its feature-local elevated script, as the privacy configuration is.

If a system feature cannot be expressed reliably with DSC and genuinely needs
procedural setup, give that feature its own directory, following the wallpaper
pattern:

```text
system/<feature>/
├── apply.ps1
└── ...
```

Do not add feature-specific logic directly to `update.ps1`.

## Design rules

- Prefer a tool's native declaration/configuration format.
- Prefer DSC for Windows desired state.
- Keep application-specific procedural work beside the application.
- Keep system-specific procedural work beside the system feature.
- Keep `update.ps1` as an orchestration list, not a configuration engine.
- Do not duplicate package lists in PowerShell.
- Avoid background PowerShell loops, Scheduled Tasks, and registry hacks when a
  stable application or Windows mechanism already exists.
