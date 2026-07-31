# Profiles

Profiles are host-selectable compositions of independently owned units. They
describe why a group of units is enabled; application, service, system, and
hardware configuration remains in its owning unit.

## Layers

| Namespace    | Purpose                                                 | Compatibility   |
| ------------ | ------------------------------------------------------- | --------------- |
| `base`       | Invariants required by every host                       | NixOS and macOS |
| `interface`  | Command-line and graphical ways to operate a host       | Per-profile     |
| `platform`   | NixOS foundation and physical or virtual hardware shape | NixOS           |
| `workload`   | Optional activities performed on a host                 | Per-profile     |
| `networking` | Network roles and topology                              | Per-profile     |
| `security`   | Optional security and secret-management policies        | Per-profile     |

`base` intentionally contains only `systems.nix`. A unit belongs there only
when removing it from any supported host would make that host invalid.

## Compatibility

| Profile                              | Supported host class                          |
| ------------------------------------ | --------------------------------------------- |
| `base`                               | NixOS, macOS                                  |
| `interface.cli`                      | NixOS, macOS with Home Manager                |
| `interface.gui`                      | NixOS, macOS with Home Manager                |
| `interface.macos`                    | macOS                                         |
| `interface.linux-desktop`            | NixOS with Home Manager                       |
| `interface.labwc`                    | NixOS with Home Manager                       |
| `interface.niri`                     | NixOS with Home Manager                       |
| `platform.nixos`                     | NixOS                                         |
| `platform.desktop`                   | Physical NixOS desktop                        |
| `platform.intel-nvidia-desktop`      | Intel/NVIDIA physical NixOS desktop           |
| `platform.laptop`                    | Physical NixOS laptop                         |
| `platform.thinkpad-x1`               | Intel ThinkPad X1 running NixOS               |
| `platform.vm`                        | UEFI QEMU NixOS guest with NFS client support |
| `workload.development`               | NixOS, macOS with Home Manager                |
| `workload.game`                      | NixOS, macOS                                  |
| `workload.personal`                  | NixOS, macOS with Home Manager                |
| `workload.remote-access`             | NixOS, macOS                                  |
| `workload.server`                    | NixOS, macOS with Home Manager                |
| `networking.tailscale-client`        | NixOS, macOS                                  |
| `networking.tailscale-subnet-router` | NixOS                                         |
| `security.fingerprint`               | NixOS, macOS                                  |
| `security.secrets`                   | NixOS, macOS                                  |
| `security.secure-boot`               | NixOS                                         |
| `security.tpm-storage`               | NixOS with a host-defined LUKS device         |

Select independent concerns independently in `hosts/default.nix`. For example,
a NixOS desktop can combine `interface.labwc` and `interface.niri` to provide
both sessions while sharing `interface.linux-desktop` and `interface.gui`.
The shared Linux desktop profile provides the common desktop applications and
session-independent services; both session profiles select ly. The laptop
platform selects niri as Ly's default session, while the desktop platform
selects labwc. A daily-use macOS development machine can combine `interface.macos`,
`workload.development`, and `workload.personal`. Hardware support does not
implicitly select an interface or workload.

`security.tpm-storage` deliberately does not own a disk identifier. A host that
selects it must define `boot.initrd.luks.devices.cryptroot.device` in its
machine-specific NixOS module.
