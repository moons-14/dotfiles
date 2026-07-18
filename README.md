# dotfiles

My NixOS + Home Manager configurations built with flake-parts.

## Overview

- **OS**: NixOS 26.05 (stable) + nixpkgs-unstable
- **Window Manager**: Niri (Wayland)
- **Shell**: Zsh
- **Terminal**: Ghostty
- **Editor**: Neovim (nixvim), VSCode
- **Launcher**: Vicinae
- **Theme**: Stylix (Dracula)
- **Secrets**: sops-nix + age + YubiKey

## Hosts

| Host          | Description     | Profiles                                     |
| ------------- | --------------- | -------------------------------------------- |
| `x1g13`       | ThinkPad laptop | gui, thinkpad, dev, personal, secure-storage |
| `nix-example` | VM              | cli-interactive, vm, dev, remote             |
| `installer`   | NixOS installer | (standalone)                                 |

## Directory Structure

```
.
├── flake.nix              # Flake inputs and outputs
├── flake/
│   ├── formatter.nix      # treefmt configuration (nixfmt, deadnix, statix, etc.)
│   └── git-hooks.nix      # pre-commit hooks
├── hosts/
│   ├── default.nix        # mkSystem helper and host definitions
│   ├── x1g13/             # ThinkPad host config
│   ├── nix-example/       # VM host config
│   └── installer/         # Installer ISO config
├── modules/
│   ├── applications/      # Application configs (NixOS + Home Manager)
│   │   ├── niri/          # Wayland compositor
│   │   ├── ghostty/       # Terminal emulator
│   │   ├── vim/           # Neovim (nixvim)
│   │   ├── vscode/        # VSCode
│   │   ├── zsh/           # Shell
│   │   ├── zellij/        # Terminal multiplexer
│   │   ├── git/           # Git config
│   │   ├── docker.nix     # Container runtime
│   │   ├── tailscale.nix  # VPN
│   │   ├── claude/        # Claude Code
│   │   ├── opencode.nix   # OpenCode
│   │   └── ...            # chrome, discord, zoom, slack, etc.
│   ├── system/            # NixOS system configs
│   │   ├── audio.nix      # PipeWire
│   │   ├── boot/          # Bootloader (systemd-boot, lanzaboote)
│   │   ├── disko.nix      # Disk partitioning
│   │   ├── fonts.nix      # Fonts
│   │   ├── network/       # Networking
│   │   ├── sops.nix       # Secrets management
│   │   ├── user/          # User accounts
│   │   └── ...
│   ├── features/          # Feature bundles (abstraction layer)
│   │   ├── application/   # browser, communication
│   │   ├── boot/          # UEFI
│   │   ├── cli/           # base, interactive, shell
│   │   ├── connect/       # WiFi, Bluetooth
│   │   ├── dev/           # agent, nix, python, bun, java, arduino
│   │   ├── gui/           # desktop, terminal, audio, editor, capture
│   │   ├── identity/      # SSH key, fingerprint
│   │   ├── network/       # Tailscale
│   │   ├── services/      # container, KDE
│   │   └── storage/       # disko
│   ├── drivers/           # Hardware drivers (Intel)
│   └── integrations/      # Home Manager integration
├── profiles/
│   ├── interfaces/        # cli-minimal, cli-interactive, gui
│   ├── platforms/         # desktop, laptop, thinkpad, vm
│   └── workloads/         # dev, personal, srv, remote, secure-storage
├── overlays/              # nixpkgs overlays
├── shells/                # devShells (pre-commit hooks, sops, age)
├── secrets/               # Encrypted secrets (sops)
└── docs/                  # Documentation
```

## Architecture

```
profile (enable features)
  → features (bundle applications/system + add packages)
    → applications (system.nix + home.nix)
    → system (NixOS config)
```

### Module Patterns

**Simple Module** — Single file for NixOS-only or Home Manager-only configs:

```nix
{ lib, config, ... }:
let cfg = config.my.system.audio;
in {
  options.my.system.audio.enable = lib.mkEnableOption "Audio";
  config = lib.mkIf cfg.enable { ... };
}
```

**Complex Module** — Directory with `default.nix`, `system.nix`, `home.nix`:

```
modules/applications/<app>/
├── default.nix    # Master enable + imports
├── system.nix     # NixOS config
└── home.nix       # Home Manager config (sharedModules)
```

**Feature Module** — Bundles multiple applications/system modules:

```nix
{ lib, config, ... }:
let cfg = config.my.features.gui.desktop;
in {
  options.my.features.gui.desktop.enable = lib.mkEnableOption "Desktop";
  config = lib.mkIf cfg.enable {
    my.applications = { niri.enable = true; gtk.enable = true; ... };
  };
}
```

**Profile** — Thin layer that only enables features:

```nix
{
  my.features = {
    gui.desktop.enable = true;
    dev.agent.enable = true;
  };
}
```

## Packages

### CLI

- **Shell**: Zsh with zoxide, direnv
- **Terminal multiplexer**: Zellij
- **Editor**: Neovim (nixvim)
- **Tools**: ripgrep, curl, wget, htop, btop, fastfetch, unzip, unrar

### GUI

- **Compositor**: Niri
- **Terminal**: Ghostty, Alacritty
- **Editor**: VSCode
- **Browser**: Chrome
- **Launcher**: Vicinae
- **File manager**: Nautilus
- **Communication**: Discord, Zoom, Slack

### Development

- **AI agents**: Claude Code, Codex, OpenCode, Grok
- **Languages**: Python, Bun (JavaScript/TypeScript), Java, Arduino
- **Container**: Docker
- **Nix**: nh, nixfmt, deadnix, statix

### System

- **VPN**: Tailscale
- **Secrets**: sops-nix, age
- **Boot**: systemd-boot, lanzaboote (Secure Boot)
- **Disk**: disko
- **Theme**: Stylix

## Commands

```sh
nix flake update                           # Update flake inputs
nix fmt                                    # Format code
nix develop .#dotnix                       # Enter dev shell
sudo nixos-rebuild switch --flake .#<host> # Apply config
sudo nixos-rebuild build --flake .#<host>  # Build without applying
```

## Nix Binary Cache

All normal hosts run `nixcache-oci` as a local proxy for
`ghcr.io/moons-14/dotfiles/nix-cache`. The `Publish Nix cache` workflow builds
the flake on pushes to `main` and uploads only store paths that were built by
the runner rather than substituted from an existing cache. Nix still uses the
official cache and configured Cachix caches for all other paths.

The cache must remain public and signed:

1. Generate a signing key outside this repository and save its contents as the
   `NIX_SIGNING_KEY` GitHub Actions secret.
2. Run the `Publish Nix cache` workflow. It commits `nixcache-public-key.txt`,
   which clients trust on their next configuration rebuild.
3. In GitHub Packages, make the `nix-cache` container package public.

```sh
nix key generate-secret > /tmp/nixcache-signing-key
# Copy the contents into the NIX_SIGNING_KEY GitHub Actions secret, then delete the local file.
```

## Inspired

- [Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos)
- [fa0311/.zshrc](https://gist.github.com/fa0311/d37d53ff39c73c54c883379e8e3732df)
- [AsianLovesLinux/Niri](https://github.com/AsianLovesLinux/Niri)
- [natsukium/dotfiles](https://github.com/natsukium/dotfiles)
- [dracula](https://github.com/dracula)
- [akazdayo/nix-configs](https://github.com/akazdayo/nix-configs)
- [yutakobayashidev/dotnix](https://github.com/yutakobayashidev/dotnix)
- [kawaemon/dotfiles](https://github.com/kawaemon/dotfiles)
