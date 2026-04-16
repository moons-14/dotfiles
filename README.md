# dotfiles

NixOS + Home Manager configuration for moons. This repository uses Nix flakes to
manage multiple NixOS hosts and project-specific development shells.

This is a personal configuration. It assumes the `moons` user, `ja_JP.UTF-8`
locale, and `Asia/Tokyo` timezone.

## Features

- NixOS 25.11 based flake configuration
- Home Manager integrated as a NixOS module
- Wayland GUI profile with Niri, Hyprland, greetd, and Noctalia
- Home Manager modules for zsh, git, btop, zellij, direnv, NixVim, fcitx5, and more
- Separate hosts for ThinkPad X1 Carbon Gen 9 / Gen 13, WSL, and server machines
- `nix develop` shells for Next.js, Jupyter, and Rust projects
- GitHub Actions + Cachix build cache for host builds
- Renovate maintenance for flake inputs and the lock file

## Hosts

The following hosts are defined in `flake.nix` under `nixosConfigurations`.

| Host | Profile | Notes |
| --- | --- | --- |
| `x1g9` | `laptop` | ThinkPad X1 9th gen, using `nixos-hardware` and the Intel driver module |
| `x1g13` | `laptop` | ThinkPad X1 13th gen, using the Intel driver module and Lanzaboote secure boot |
| `x1g13-wsl` | `cli` | NixOS-WSL with `moons` as the default user |
| `monitor` | `cli-server` | Server host |
| `dev-1` | `cli-server` | Server host |
| `service-1` | `cli-server` | Server host with Immich / Cloudreve NFS mounts |

## Profiles

Profiles live in `profiles/` and are selected per host from `flake.nix`.

| Profile | Role |
| --- | --- |
| `cli-minimal` | Minimal profile with no extra imports. Shared NixOS and Home Manager modules are still always applied |
| `cli` | CLI profile extending `cli-minimal` |
| `cli-server` | Server profile extending `cli` |
| `gui` | GUI profile extending `cli` with Niri, Hyprland, greetd, Noctalia, KDE/GUI support, and GUI Home Manager modules |
| `laptop` | Laptop profile extending `gui` with fingerprint, power, and camera modules |

## Directory Layout

```text
.
|-- flake.nix                 # inputs, host definitions, devShells
|-- flake.lock                # locked flake inputs
|-- hosts/                    # host-specific NixOS settings
|   `-- <host>/
|       |-- default.nix
|       `-- hardware-configuration.nix
|-- profiles/                 # reusable host profiles
|-- modules/
|   |-- core/                 # NixOS modules
|   |-- drivers/              # hardware / driver modules
|   `-- home/                 # Home Manager modules
|-- overlays/                 # package overlays
|-- shells/                   # nix develop environments
|-- images/                   # managed image assets
|-- renovate.json             # Renovate config
`-- .github/workflows/        # CI builds and Cachix integration
```

## System Usage

Rebuild the current machine by selecting the matching `#<host>` output.

```sh
sudo nixos-rebuild switch --flake .#x1g13
```

Switch on the next boot instead:

```sh
sudo nixos-rebuild boot --flake .#x1g13
```

Build a system closure in the same form used by CI:

```sh
nix build -L .#nixosConfigurations.x1g13.config.system.build.toplevel
```

List available hosts and development shells:

```sh
nix flake show
```

## Development Shells

`devShells.x86_64-linux` provides the following shells.

| Shell | Command | Main tools |
| --- | --- | --- |
| `next-web` | `nix develop .#next-web` | Node.js 24, pnpm, Vercel CLI, Prisma, OpenSSL, jq, ngrok |
| `jupyter` | `nix develop .#jupyter` | Python 3.12, JupyterLab, NumPy, pandas, matplotlib, scipy, scikit-learn |
| `rust` | `nix develop .#rust` | rustup, clang, LLVM/binutils, pkg-config |

To use a shell through direnv, add an `.envrc` to the target project.

```sh
use flake ~/dotfiles#next-web
```

## Adding A Host

1. Create `hosts/<host>/hardware-configuration.nix`.
   For an existing NixOS install, use the output from `sudo nixos-generate-config`.
2. Create `hosts/<host>/default.nix` and import hardware modules or host-specific settings.
3. Add a `mkSystem` entry to `nixosConfigurations` in `flake.nix` and choose a `profile`.
4. Check the build with `nix build -L .#nixosConfigurations.<host>.config.system.build.toplevel`.
5. Run `sudo nixos-rebuild switch --flake .#<host>` on the target host.

## Common Modules

### NixOS

`modules/core/default.nix` imports boot, Cachix, environment, fonts, GC, hardware,
i18n, network, packages, services, SSH, system, user, and xserver modules.

Main settings include:

- flakes / nix-command enabled
- `moons` user and Home Manager integration
- zsh, Docker, Tailscale, PipeWire, adb, Java 25, Python, Bun, Claude Code, Codex, and more
- NetworkManager, fixed nameservers, and JP Wi-Fi regulatory domain
- OpenSSH server with password login and root login disabled
- Cachix caches for `moons-dotfiles` and `vicinae`

### Home Manager

`modules/home/default.nix` imports btop, git, fcitx5, SSH, NixVim, zsh, direnv,
zellij, and Claude configuration.

The GUI profile additionally manages Niri, VS Code, Google Chrome, Vicinae,
Noctalia, Ghostty, wallpaper, lock screen, Discord, Nautilus, GTK, and Zoom.

NixVim is split into modules for LSP, formatters, completion, git integration,
UI plugins, editor plugins, options, keymaps, and autocmds.

## Manual Steps

The following setup is not fully declarative or needs host-specific manual work.

- Register an SSH public key with GitHub.
- Enroll fingerprints on laptop hosts.

```sh
fprintd-enroll
```

- `x1g13` uses Lanzaboote / sbctl for secure boot. The PKI bundle is read from
  `/var/lib/sbctl`.
- Log in to services that require authentication, such as Tailscale and 1Password.

## Maintenance

Update all flake inputs:

```sh
nix flake update
```

Update a single input:

```sh
nix flake lock --update-input nixpkgs
```

GitHub Actions builds all hosts when `flake.nix`, `flake.lock`, `hosts/**`,
`modules/**`, `profiles/**`, or `overlays/**` changes. Pushes to `main` upload
to the `moons-dotfiles` Cachix cache.

Renovate enables Nix lock file maintenance and has a separate package rule for
`llm-agents`.

## Inspired

- [Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos)
- [fa0311/.zshrc](https://gist.github.com/fa0311/d37d53ff39c73c54c883379e8e3732df)
- [AsianLovesLinux/Niri](https://github.com/AsianLovesLinux/Niri)
- [natsukium/dotfiles](https://github.com/natsukium/dotfiles)
- [dracula](https://github.com/dracula)
- [akazdayo/nix-configs](https://github.com/akazdayo/nix-configs)
- [yutakobayashidev/dotnix](https://github.com/yutakobayashidev/dotnix)
