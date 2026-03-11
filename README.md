# dotfiles

NixOS + Home Manager

## Pickup Software

- Window Manager: Niri
- Lancher: Vicinae
- Bar: Noctalia
- Editor: msedit, neovim, vscode
- Terminal: ghostty, oh-my-zsh

## Directory Structure

- hosts/{host-name}<br/>
  Hardware-specific configurations that abstract differences between hardware. Keep these minimal. Add new configurations when running NixOS on new hardware without existing support.
  - default.nix<br/>
    Moved from `/etc/nixos/configuration.nix`
  - hardware-configuration.nix<br/>
    Run `sudo nixos-generate-config` or moved from `/etc/nixos/hardware-configuration.nix`
  - variables.nix<br/>
    Config
- images
- modules
  - core<br/>
    Files related to NixOS configuration
  - drivers<br/>
    Files related to drivers such as GPUs
  - home<br/>
    Home-manager configuration files
- profiles<br/>
  Build configurations for each environment by combining NixOS configurations and home-manager configurations.
- shells<br/>
  Shell environment.

## Declarative Defeat

Necessary configurations not achievable with dotfiles

### Profile: cli-minimal

- SSH key registration
  Please register the value of ~/.ssh/id_ed25519.pub on GitHub.

### Profile: laptop

- Fingerprint registration
  Please register the user's fingerprints by running fprintd-enroll.

## Inspired

- [Zaney/zaneyos](https://gitlab.com/Zaney/zaneyos)
- [fa0311/.zshrc](https://gist.github.com/fa0311/d37d53ff39c73c54c883379e8e3732df)
- [AsianLovesLinux/Niri](https://github.com/AsianLovesLinux/Niri)
- [natsukium/dotfiles](https://github.com/natsukium/dotfiles)
- [dracula](https://github.com/dracula)
- [akazdayo/nix-configs](https://github.com/akazdayo/nix-configs)
- [yutakobayashidev/dotnix](https://github.com/yutakobayashidev/dotnix)
