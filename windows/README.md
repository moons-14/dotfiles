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
│   ├── explorer.dsc.yaml
│   ├── ime.dsc.yaml
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
& .\system\wallpaper\apply.ps1
```

The specialized scripts own the details of their own configuration.

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
- 7-Zip

ChatGPT is intentionally not part of this DSC file because its Microsoft Store
installation requires explicit package/source agreement acceptance.

### ChatGPT

`applications/chatgpt/apply.ps1` uses OpenAI's documented WinGet installation:

```powershell
winget install `
    --id 9NT1R1C2HH7J `
    --source msstore `
    --accept-package-agreements `
    --accept-source-agreements `
    --silent `
    --disable-interactivity
```

The Store product ID `9NT1R1C2HH7J` is the ChatGPT Windows app. The previously
used `9PLM9XGG6VKS` ID is not used here.

7-Zip is intentionally installed with its normal Windows installer through
WinGet rather than as a portable Scoop package, because the normal installer
provides Explorer shell integration.

## Windows settings

### Taskbar

`system/taskbar.dsc.yaml` configures:

- Widgets: off
- Resume: off
- Search: icon only
- Alignment: left

### Explorer

`system/explorer.dsc.yaml` configures:

- show known file extensions

7-Zip context-menu integration is left to the official 7-Zip installer. No
unsupported Explorer context-menu patches are applied.

### Microsoft IME

`system/ime.dsc.yaml` configures:

- Muhenkan: IME Off
- Henkan: IME On

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
system/explorer.dsc.yaml
system/ime.dsc.yaml
system/privacy.dsc.yaml
```

When adding a new DSC document, include it from `configuration.dsc.yaml`.

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
