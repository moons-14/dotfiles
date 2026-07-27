# Repository Guidelines

## Project Structure and Ownership

This repository manages NixOS, nix-darwin, and Home Manager configurations as a
flake. `flake.nix` defines inputs and delegates flake outputs through
flake-parts. Keep configuration with the component that owns it, rather than in
the root flake or an unrelated host.

This file documents the current repository contract, not a hypothetical future
layout. When a structural, ownership, profile, host-role, or validation change
makes any statement here stale, update `AGENTS.md` in the same change.

| Path                    | Responsibility                                                                                                    |
| ----------------------- | ----------------------------------------------------------------------------------------------------------------- |
| `modules/applications/` | One software component, including GUI applications, window managers, desktop environments, CLI tools, and editors |
| `modules/systems/`      | OS foundations such as Nix, boot, locale, Wayland, and networking                                                 |
| `modules/services/`     | Daemons, long-running services, and configuration that involves permissions or user groups                        |
| `modules/hardwares/`    | Reusable drivers, hardware families, and VM or WSL guest configuration                                            |
| `modules/users/`        | User identity and the user's NixOS-, nix-darwin-, and Home Manager-specific definitions                           |
| `modules/profiles/`     | Purpose- or form-factor-oriented compositions of multiple units                                                   |
| `hosts/`                | Machine-specific facts and the profiles selected for each machine; direct unit selections are exceptional         |
| `libs/`                 | Registry, unit discovery, and host construction logic                                                             |
| `overlays/`             | Package replacements and additions                                                                                |
| `shells/`               | Development shells                                                                                                |
| `flake/`                | Supporting flake outputs such as formatters, checks, and Git hooks                                                |

Use **unit** as the generic internal term for a Registry-managed component and
**profile** for a unit that composes multiple units. Do not introduce a
`features/` layer. Window managers and desktop environments such as niri and
GNOME belong in `modules/applications/`; do not create a separate `desktop/`
module category.

Before adding configuration, decide whether it is owned by an application,
system foundation, service, hardware family, user, profile, or individual host.
Prefer the following placements:

| Configuration                                        | Placement                                               |
| ---------------------------------------------------- | ------------------------------------------------------- |
| Nix settings shared by every system host             | `modules/systems/nix/common.nix`                        |
| NixOS-only boot configuration                        | `modules/systems/boot/.../nixos.nix`                    |
| macOS Dock defaults                                  | `modules/systems/dock/darwin.nix`                       |
| macOS trackpad defaults                              | `modules/systems/trackpad/darwin.nix`                   |
| Ghostty-specific configuration                       | `modules/applications/ghostty/`                         |
| niri-specific configuration                          | `modules/applications/niri/`                            |
| Desktop applications shared by GNOME and niri        | `modules/profiles/interface/linux-desktop/meta.nix`     |
| Applications and services specific to niri           | `modules/profiles/interface/niri/meta.nix`              |
| GNOME itself                                         | `modules/applications/gnome/`                           |
| A Linux package plus its macOS Homebrew cask         | `modules/applications/<name>/home.nix` and `darwin.nix` |
| Docker daemon and Docker group membership            | `modules/services/docker/nixos.nix`                     |
| The laptop unit composition                          | `modules/profiles/platform/laptop/meta.nix`             |
| The Intel ThinkPad X1 composition                    | `modules/profiles/platform/thinkpad-x1/meta.nix`        |
| The development-environment unit composition         | `modules/profiles/workload/development/meta.nix`        |
| Cross-platform fingerprint selection                 | `modules/profiles/security/fingerprint/meta.nix`        |
| A user's OS- and Home Manager-specific configuration | `modules/users/<name>/`                                 |
| Host-specific monitor layout                         | `hosts/<name>/home.nix`                                 |
| Generated host disk UUIDs                            | `hosts/<name>/hardware-configuration.nix`               |
| Package replacement or addition                      | `overlays/`                                             |
| Formatter, checks, or Git hooks                      | `flake/`                                                |

## Unit Discovery and Identity

A directory below `modules/` is a unit if, and only if, it directly contains at
least one reserved file. Directories used only for classification, such as
`modules/applications/` or `modules/profiles/interface/`, are namespaces rather
than units when they have no reserved file of their own.

The Registry recognizes exactly these five reserved filenames:

| File         | Target and responsibility                                                        |
| ------------ | -------------------------------------------------------------------------------- |
| `common.nix` | System-side configuration fragment shared by NixOS and nix-darwin                |
| `nixos.nix`  | NixOS-only configuration fragment                                                |
| `darwin.nix` | nix-darwin-only configuration fragment                                           |
| `home.nix`   | Home Manager configuration fragment                                              |
| `meta.nix`   | Registry descriptor for dependencies, external modules, and descriptive metadata |

`common.nix` is never applied to Home Manager. OS-independent Home Manager
configuration still belongs in `home.nix`.

The Registry derives a unit ID from the path relative to `modules/`, joining
path components with dots. Category names remain plural. It also derives the
enable option by prefixing the same components with `my` and appending `enable`.

| Unit directory                     | Unit ID                   | Enable option                       |
| ---------------------------------- | ------------------------- | ----------------------------------- |
| `modules/applications/ghostty/`    | `applications.ghostty`    | `my.applications.ghostty.enable`    |
| `modules/applications/niri/`       | `applications.niri`       | `my.applications.niri.enable`       |
| `modules/systems/boot/uefi/`       | `systems.boot.uefi`       | `my.systems.boot.uefi.enable`       |
| `modules/services/docker/`         | `services.docker`         | `my.services.docker.enable`         |
| `modules/hardwares/qemu-guest/`    | `hardwares.qemu-guest`    | `my.hardwares.qemu-guest.enable`    |
| `modules/users/moons/`             | `users.moons`             | `my.users.moons.enable`             |
| `modules/profiles/interface/niri/` | `profiles.interface.niri` | `my.profiles.interface.niri.enable` |

Represent option paths as attribute-path lists, never as Nix source encoded in
strings or evaluated dynamically. Generate and read attributes with helpers such
as `lib.setAttrByPath` and `lib.getAttrFromPath`:

```nix
{
  id = "applications.ghostty";

  optionPath = [
    "my"
    "applications"
    "ghostty"
    "enable"
  ];

  kind = "applications";
  name = "ghostty";

  relativePath = [
    "applications"
    "ghostty"
  ];
}
```

For `modules/profiles/interface/niri/`, path inference additionally gives
`kind = "profiles"`, `group = "interface"`, and `name = "niri"`. The path is
always authoritative for identity. `meta.nix` may provide display metadata such
as `description`, but it must not override or alias the unit ID.

## Unit Files and Fragment Contract

Only reserved files that a unit actually needs should exist. The Registry
registers present fragments and does not require empty or placeholder files. All
of the following are valid units:

```text
# Home Manager only
modules/applications/ghostty/
├── home.nix
└── settings.nix

# NixOS only
modules/applications/gnome/
└── nixos.nix

# nix-darwin only
modules/systems/macos-defaults/
└── darwin.nix

# NixOS and Home Manager, with metadata and helpers
modules/applications/niri/
├── nixos.nix
├── home.nix
├── meta.nix
├── settings.nix
└── keybindings.nix

# Metadata only, commonly a composition profile
modules/profiles/interface/niri/
└── meta.nix

# System configuration shared by NixOS and nix-darwin
modules/systems/nix/
└── common.nix
```

If a unit has no `home.nix`, do not generate or apply a Home Manager module for
it. The same rule applies independently to `common.nix`, `nixos.nix`, and
`darwin.nix`.

### Configuration fragments

`common.nix`, `nixos.nix`, `darwin.nix`, and `home.nix` are configuration
fragments to which the Registry adds the enable condition. They return the
configuration for their class directly and must not define top-level `imports`,
`options`, or `config` attributes:

```nix
# modules/services/docker/nixos.nix
{ primaryUser, ... }:
{
  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
  };

  users.users.${primaryUser}.extraGroups = [
    "docker"
  ];
}
```

Conceptually, the Registry supplies a wrapper like this:

```nix
{ config, lib, ... }@args:
{
  config =
    lib.mkIf
      config.my.services.docker.enable
      (import dockerNixosPath args);
}
```

Do not add hand-written `mkEnableOption`, `cfg`, or `mkIf` boilerplate to each
unit. The Registry generates the enable option from the unit path and guards the
fragment.

### Helper files and directories

Every filename other than the five reserved names is an ordinary helper,
regardless of its extension. The Registry neither discovers nor automatically
imports helper files such as `settings.nix`, `keybindings.nix`, `packages.nix`,
`colors.nix`, `rules.nix`, or `helpers.nix`. Import a helper explicitly from the
reserved fragment that uses it:

```nix
# modules/applications/niri/home.nix
{ lib, ... }:
let
  settings = import ./settings.nix;
  keybindings = import ./keybindings.nix;
in
{
  programs.niri.settings = lib.recursiveUpdate settings {
    binds = keybindings;
  };
}
```

Do not use a leading underscore to mark a file private; `_settings.nix` has no
special meaning. Give helper files descriptive names instead. When helpers are
configuration functions, pass the module arguments explicitly and combine them
with normal Nix expressions:

```nix
# modules/applications/example/home.nix
{ lib, ... }@args:
lib.mkMerge [
  (import ./packages.nix args)
  (import ./settings.nix args)
]
```

The same discovery rule applies recursively to helper directories:

```text
modules/applications/niri/
├── home.nix
└── parts/
    ├── appearance.nix
    └── keybindings.nix
```

Here `parts/` is not a unit because it directly contains no reserved file. A
helper directory that directly contains `home.nix` or another reserved file is
itself discovered as a unit, so never use reserved filenames inside a directory
that is intended to contain helpers only.

### Registry metadata

`meta.nix` is a Registry descriptor, not a NixOS, nix-darwin, or Home Manager
module. It may declare `description`, `includes`, and class-specific external
module imports:

```nix
# modules/applications/niri/meta.nix
{ inputs, ... }:
{
  description = "Niri Wayland compositor";

  includes = [
    "systems.wayland"
    "services.xdg-portal"
  ];

  imports.nixos = [
    inputs.niri-flake.nixosModules.niri
  ];

  imports.home = [
    inputs.niri-flake.homeModules.niri
  ];
}
```

External modules, including modules supplied by flake inputs, define Nix module
options and therefore belong in `meta.nix` under `imports.nixos`,
`imports.darwin`, or `imports.home`. Do not place them in a configuration
fragment's top-level `imports`: the Nix module system resolves imports before a
configuration-level enable condition.

`includes` lists units to enable whenever the declaring unit is enabled. Always
use fully qualified unit IDs:

```nix
# modules/profiles/interface/niri/meta.nix
{
  includes = [
    "profiles.interface.linux-desktop"
    "applications.niri"
    "applications.noctalia"
    "services.ly"
    "services.swayidle"
    "services.swaylock"
  ];
}
```

Never omit a prefix such as `applications.` merely because the including unit is
a profile. Fully qualified IDs make ownership explicit and allow moves, name
collisions, and missing dependencies to be detected. Do not enable another unit
by assigning to its enable option from a class fragment; declare the dependency
in `meta.includes`.

Application metadata should include only dependencies technically required for
the application to work. A profile owns the user's choice to adopt several
otherwise independent applications together. For example, the niri application
includes the Wayland foundation as a technical dependency. The
`profiles.interface.linux-desktop` profile selects Ghostty, Nautilus, and
Vicinae because both GNOME and niri use them, while `profiles.interface.niri`
selects only the niri-specific shell and services. Ghostty must not depend on
niri, and niri-specific keybindings remain owned by the niri unit.

## Profiles

Profiles compose units by purpose or form factor; they do not replace clear
application, system, service, or hardware ownership. The current profile
structure is:

```text
modules/profiles/
├── README.md
├── base/
├── interface/
│   ├── cli/
│   ├── macos/
│   ├── linux-desktop/
│   ├── gnome/
│   └── niri/
├── networking/
│   ├── tailscale-client/
│   └── tailscale-subnet-router/
├── platform/
│   ├── nixos/
│   ├── laptop/
│   ├── thinkpad-x1/
│   ├── desktop/
│   └── vm/
├── workload/
│   ├── development/
│   ├── personal/
│   ├── server/
│   └── remote-access/
└── security/
    ├── fingerprint/
    ├── secrets/
    ├── secure-boot/
    └── tpm-storage/
```

`modules/profiles/README.md` is the compatibility inventory for this structure.
Whenever a profile is added, removed, renamed, changes host-class support, or
changes meaning, update that README and every affected `hosts/default.nix`
selection in the same change. Remove stale profile directories and references;
do not retain compatibility aliases.

The profile layers have these responsibilities:

- `base` contains only invariants required by every supported host. It currently
  includes only `systems.nix`; optional secrets, interface, hardware, and
  workloads do not belong there.
- `interface` describes how the host is operated. `interface.cli` is shared by
  NixOS and macOS and includes `tio`. `interface.macos` owns the macOS Dock and
  trackpad defaults. `interface.linux-desktop` owns the common GNOME/niri
  desktop selection, including Ghostty, Nautilus, and Vicinae. GNOME and niri
  remain independently selectable and do not imply CLI or personal workloads.
- `platform` describes NixOS foundations and physical or virtual form factors.
  macOS does not need an empty symmetric platform profile.
- `workload` describes optional host uses. `workload.development` and
  `workload.personal` are cross-platform profiles, not `*-linux` variants.
- `networking` describes network roles and topology rather than user workloads.
- `security` describes optional security policies. Select
  `security.fingerprint` instead of listing `systems.fingerprint` directly in a
  host. The underlying `systems.fingerprint` unit owns NixOS fingerprint
  authentication and macOS Touch ID sudo configuration through its class
  fragments.

Do not split a semantic profile into `*-linux` and cross-platform variants merely
because an application is installed differently on each OS. Keep the semantic
profile cross-platform when its purpose is shared, and implement OS differences
inside the owning application unit. For example, Chrome, Vesktop, draw.io,
Slack, and Zoom use Linux Home Manager configuration in `home.nix` and macOS
Homebrew casks in `darwin.nix`. Guard a Linux-only Home Manager package with the
host platform when the same unit also has a Darwin implementation.

An explicitly OS-specific profile is appropriate when the composition itself is
OS-specific, such as `interface.macos`, `interface.linux-desktop`,
`platform.nixos`, or a NixOS
subnet-router. Do not create an OS suffix for a thin package difference that the
owning application unit can express.

The `desktop/` name above is a form-factor profile under `profiles/platform/`,
not a top-level module category.

A profile may consist only of `meta.includes`. Small settings that belong only
to the composition and have no useful independent identity may go directly in
the profile's `nixos.nix`, `darwin.nix`, or `home.nix`. Extract configuration to
an appropriate application, system, service, or hardware unit when any of these
conditions holds:

- It should be independently enableable.
- Multiple profiles reuse it.
- It owns separate configuration files.
- Its NixOS, nix-darwin, and Home Manager implementations differ.
- Other units depend on it.
- It involves a daemon, permissions, or user groups.

`security.tpm-storage` intentionally does not own a disk identifier. A host that
selects it must define `boot.initrd.luks.devices.cryptroot.device` in its own
NixOS module.

## Registry Responsibilities

Implement unit discovery with Nix standard functionality such as
`builtins.readDir`. Do not depend on an external indiscriminate auto-import
mechanism, and do not design the repository around `import-tree`. Registry logic
has these responsibilities:

1. Recursively visit directories below `modules/`.
2. Check only the five reserved filenames directly within each directory.
3. Register a directory as a unit when at least one reserved file exists there.
4. Derive the unit ID from the path relative to `modules/`.
5. Record only class fragments that exist.
6. Evaluate `meta.nix` as a descriptor only when it exists.
7. Exclude non-reserved files from discovery and implicit imports.
8. Generate every unit's `my.<unit path>.enable` option.
9. Enable included units from `meta.includes`.
10. Raise a clear evaluation error for a reference to a missing unit ID.
11. Apply only the fragments appropriate to the current host class.
12. Pass `home.nix` to Home Manager only for hosts that enable Home Manager.

A unit record may conceptually look like this; the implementation need not use
this exact representation:

```nix
{
  id = "applications.ghostty";
  directory = ./applications/ghostty;

  fragments = {
    common = null;
    nixos = null;
    darwin = null;
    home = ./applications/ghostty/home.nix;
  };

  meta = { };
}
```

Keep the custom Registry limited to unit discovery, enable-option generation,
`includes`, and class dispatch. Do not reimplement general Nix imports or Nix
module evaluation. In particular, never infer a unit ID from metadata or
implicitly load a non-reserved file.

## Hosts and Class Dispatch

`hosts/` is outside Registry discovery. A host contains machine-specific facts,
differences, and unit selection, not reusable shared configuration. Appropriate
host-owned data includes:

- Generated `hardware-configuration.nix`.
- Disk UUIDs and disko target devices.
- Monitor identifiers, layout, and scale.
- MAC addresses and static IP addresses.
- Kernel parameters required by one machine only.
- `system.stateVersion`.
- Host-specific secret references.
- The profiles enabled on that host and, only in exceptional cases, direct
  application or other unit selections that cannot be expressed by a coherent
  reusable profile.

A host registry may use a specification like this:

```nix
# hosts/default.nix
{
  x1g9 = {
    system = "x86_64-linux";
    stateVersion = "26.05";
    user = "moons";
    path = ./x1g9;

    profiles = [
      "base"
      "interface.cli"
      "interface.gnome"
      "interface.niri"
      "platform.thinkpad-x1"
      "security.fingerprint"
      "workload.personal"
    ];
  };

  m2 = {
    system = "aarch64-darwin";
    stateVersion = "26.05";
    user = "moons";
    path = ./m2;

    profiles = [
      "base"
      "interface.cli"
      "interface.macos"
      "security.fingerprint"
      "workload.development"
      "workload.personal"
    ];
  };
}
```

The current role assignment is intentional: x1g9 is a full NixOS desktop with
niri, GNOME, ly, the shared Linux desktop applications, and the personal
workload. m2 is the daily-use macOS development and personal machine with the
macOS interface defaults. Keep the desktop sessions independently selectable,
and keep m2's development and personal profiles usable on Darwin.

Treat entries in `profiles` and the exceptional `applications` field as IDs
relative to their respective category roots. Add the category prefixes during
host construction:

```nix
selectedUnits =
  [ "users.${spec.user}" ]
  ++ map (name: "profiles.${name}") spec.profiles
  ++ map (name: "applications.${name}") spec.applications
  ++ spec.units or [ ];
```

`applications` and `units` are escape hatches, not normal host composition.
Do not add either field when an existing profile expresses the concern, when an
existing profile can coherently include the unit, or when the concern is
reusable enough to deserve a small profile. For example, add a development tool
to `workload.development` and select `security.fingerprint`; do not write
`applications = [ "ghostty" ];` or `units = [ "systems.fingerprint" ];` in a
host. A direct selection is permitted only for a genuinely exceptional,
machine-specific unit that would make every reasonable profile misleading; add
an adjacent comment explaining that exception. Prefer profiles for host
composition and omit both escape-hatch fields by default.

Host modules use normal Nix module semantics and are not Registry-guarded
configuration fragments. For example:

```text
hosts/
├── x1g9/
│   ├── nixos.nix
│   └── hardware-configuration.nix
└── m2/
    └── darwin.nix
```

`hosts/x1g9/nixos.nix` explicitly loads `hardware-configuration.nix` with the
normal top-level Nix module `imports`. A future host-local `disko.nix` would be
loaded the same way. Do not confuse these host imports with the prohibition on
top-level `imports` in unit configuration fragments.

Derive the system class from the host's `system`:

- A Linux NixOS host receives `common.nix` and `nixos.nix`.
- A nix-darwin host receives `common.nix` and `darwin.nix`.
- A host with integrated Home Manager additionally receives `home.nix`.

Home Manager is additive, not a system class mutually exclusive with NixOS or
nix-darwin. The supported combinations are NixOS plus Home Manager and
nix-darwin plus Home Manager. If standalone Home Manager is supported later, add
an explicit host kind because `system` alone cannot distinguish it from NixOS.

Do not duplicate reusable settings in hosts, but do not force genuinely
machine-specific values into a common unit merely to remove a host-local line.

## Coding Style and Implementation Rules

Use two-space indentation in Nix files and let `nixfmt` decide layout. Prefer
small units, explicit imports, and descriptive kebab-case names, for example
`modules/services/media-server/nixos.nix`. Use camelCase for Nix attributes
unless an upstream option dictates otherwise. Shell snippets must pass `shfmt`
and `shellcheck`; YAML, TOML, and Markdown are formatted by the configured
treefmt tools.

When implementing or modifying modules:

- Do not create `features/` or a top-level `desktop/` module category.
- Do not add per-unit `mkEnableOption`, `cfg`, or `mkIf` boilerplate; the Registry
  derives and guards enable options from paths.
- Put unit dependencies in `meta.includes`, not in direct assignments to another
  unit's enable option from a class fragment.
- Do not assume any non-reserved file is discovered or loaded automatically.
- Do not require an `_` prefix for helper or private files.
- Do not create unused `common.nix`, `nixos.nix`, `darwin.nix`, `home.nix`, or
  `meta.nix` files.
- Do not override a path-derived unit ID from `meta.nix`.
- Keep technical application dependencies separate from the applications a
  personal environment chooses to combine in a profile.
- Keep cross-platform profile names semantic. Put Linux package installation in
  an application's `home.nix` and the corresponding macOS Homebrew cask in its
  `darwin.nix`; do not create a thin `*-linux` profile for that difference.
- Keep shared GNOME/niri selections in `profiles.interface.linux-desktop` and
  session-specific applications or services in the respective GNOME or niri
  profile.
- Keep `modules/profiles/README.md`, the profile directories, and host profile
  selections synchronized whenever any of them changes.
- Do not select applications or units directly in `hosts/default.nix` unless
  they meet the documented exceptional, machine-specific escape-hatch rule.
  Prefer adding the unit to an existing coherent profile or creating a small,
  justified reusable profile.
- Do not rely on module-list ordering to override values. Use Nix module
  priorities such as `lib.mkDefault`, `lib.mkForce`, `lib.mkBefore`, or
  `lib.mkAfter` explicitly when required.
- Keep Registry responsibilities narrow; use normal Nix imports and module
  evaluation for everything outside discovery, generated enables, includes, and
  class dispatch.

## Build, Test, and Development Commands

- `nix develop .#dotnix` enters the main development shell and installs the
  repository's pre-commit hooks.
- `nix develop .#android` provides Android platform tools such as `adb` and
  `fastboot`.
- `nix fmt` formats all supported files through treefmt.
- `nix flake check` evaluates flake outputs and runs configured checks.
- `pre-commit run --all-files` runs formatting, dead-code and static Nix checks,
  shell linting, and secret scanning.
- `nix flake update` refreshes pinned inputs in `flake.lock`; review lockfile
  changes before committing.

If direnv is installed, `direnv allow` activates the `dotnix` shell from `.envrc`
automatically.

## Testing Guidelines

There is no separate unit-test suite. Before submitting changes, run
`nix flake check` and `pre-commit run --all-files`. For system-specific changes,
also build or evaluate the affected NixOS, nix-darwin, or Home Manager
configuration without switching the live machine. Never commit generated
secrets, `.age` plaintext, or local `.direnv/` state.

For Registry changes, test discovery of each supported fragment combination,
dependency closure through `meta.includes`, missing-unit errors, and class
dispatch. Verify that helper files are ignored until explicitly imported and
that directories without a directly contained reserved file remain namespaces.

For profile changes, additionally:

- Check for stale profile IDs after every add, removal, or rename.
- Evaluate every affected real host without switching it.
- Evaluate a cross-platform profile on both NixOS and nix-darwin, even when only
  one current host selects it.
- Confirm `modules/profiles/README.md` accurately states compatibility and any
  required host-owned values.
- When adding a Darwin application fragment, verify the resulting
  `homebrew.casks` selection as well as module evaluation.
- Preserve the intended host roles: x1g9 provides niri, GNOME, ly, and the
  personal application set, while m2 remains the daily-use development and
  personal machine.

## Commit and Pull Request Guidelines

Recent history favors short, lowercase, imperative subjects such as `fix` and
`update action`; automated dependency commits use `chore(deps): ...`. Prefer a
specific summary that states the affected area, such as
`shells: add deployment tools`. Keep commits focused. Pull requests should
explain the motivation, list affected hosts or profiles, report validation
commands, and note any manual migration or secret-management steps. Include
screenshots only for visible desktop or application configuration changes.
