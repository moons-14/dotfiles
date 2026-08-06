---
name: validate-nix-change
description: Plan and run efficient, non-activating validation for edits to this NixOS, nix-darwin, and Home Manager flake. Use after changing Nix modules, hosts, profiles, overlays, flake outputs, tests, scripts, CI, or agent configuration; before handing off a task; or when deciding which real hosts must be evaluated or built.
---

# Validate a Nix Change

Use the repository validation app as the source of truth for change impact and
validation commands. It derives affected hosts from Registry ownership,
`meta.includes`, host selections, fragment class, and host-local paths.

Never activate a live configuration as part of this workflow. Do not run
`nh os switch`, `nixos-rebuild switch`, `darwin-rebuild switch`,
`home-manager switch`, or an equivalent activation command. The user owns live
activation separately.

## Establish the validation scope

1. Read `AGENTS.md` and run `git status --short` before editing.
2. Preserve unrelated user changes. Track the paths owned by the current task,
   including newly created untracked files.
3. Inspect the plan before expensive checks:

```sh
nix run .#check -- plan --paths <task-path>... --json
```

When validating a committed pull-request range, use:

```sh
nix run .#check -- plan --base <base-sha> --json
```

The app automatically uses a `path:` flake reference when task paths are
untracked, so newly created Registry fragments are visible to Nix without
staging them.

## Run checks in increasing cost order

### Fast edit loop

After each coherent edit, parse Nix files, validate project JSON, TOML, and
skill frontmatter, check whitespace, and run the configured hooks only for
task-owned files:

```sh
nix run .#check -- fast --paths <task-path>...
```

Do not replace this with `pre-commit run --all-files` during the edit loop.
Unrelated repository files must not become part of the task merely because an
existing check fails elsewhere.

### Evaluation

After the implementation is structurally complete, evaluate every affected
NixOS and Darwin derivation plus the supporting checks without realizing or
activating them. Flake-wide paths additionally evaluate every flake system:

```sh
nix run .#check -- eval --paths <task-path>...
```

This proves module evaluation, option types, assertions, Registry selection,
and derivation instantiation. It does not prove a successful build or runtime
behavior.

### Compatible builds

Build affected configurations for the current platform with no result link:

```sh
nix run .#check -- build --paths <task-path>...
```

The app reports incompatible targets as evaluated but skipped for native build.
A Darwin target must be built by a compatible Darwin runner or builder; a Linux
evaluation is not a Darwin build.

### Final task validation

Before handoff, run the cumulative task check. It applies file checks only to
task-owned paths, evaluates every flake system, and builds affected native
targets:

```sh
nix run .#check -- all --paths <task-path>...
```

Use `--all-hosts` only when a deliberate audit must report every registered
host as affected. Use the exhaustive command for CI, scheduled maintenance, or
an explicit repository-wide audit:

```sh
nix run .#check -- full
```

`full` runs hooks over every tracked file and builds every check for the current
platform through `nix-fast-build`.

## Add runtime tests when needed

Evaluation and builds do not prove service startup, socket behavior, firewall
rules, users and groups, permissions, reboot behavior, or network interaction.
For reusable NixOS behavior, invoke the `test-nixos-service` skill and add a
`pkgs.testers.runNixOSTest` check. Hardware, credentials, GUI appearance, and
external services may still require a precisely described manual check after
the user activates the configuration.

## Diagnose failures by layer

Invoke the `debug-nix-failure` skill when a stage fails. Fix the first failing
layer before running a more expensive one. Do not hide a pre-existing failure,
weaken an assertion, add `lib.mkForce`, or skip a required host merely to make
the task appear green.

## Report evidence precisely

Conclude with:

- task-owned paths;
- affected units and hosts reported by `plan`;
- each command run and its result;
- which targets were parsed, evaluated, built, or runtime-tested;
- any compatible-platform or manual-runtime gap.

Never describe evaluation as a build, a build as activation, or a VM test as
proof of hardware-specific behavior.
