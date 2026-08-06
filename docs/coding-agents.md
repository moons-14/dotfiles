# Coding-agent workflow

This repository exposes deterministic validation and narrowly scoped research
tools for Codex, OpenCode, and editor agents. Live system activation is outside
this workflow.

## Validation commands

Use task-owned paths during the edit loop:

```console
nix run .#check -- plan --paths modules/applications/example/home.nix --json
nix run .#check -- fast --paths modules/applications/example/home.nix
nix run .#check -- eval --paths modules/applications/example/home.nix
nix run .#check -- build --paths modules/applications/example/home.nix
nix run .#check -- all --paths modules/applications/example/home.nix
```

For a committed pull-request range, replace `--paths ...` with
`--base <base-sha>`. `full` is reserved for CI, scheduled maintenance, or an
explicit repository-wide audit:

```console
nix run .#check -- full
```

The stages have distinct meanings:

- `plan` maps changed paths to Registry units, reverse `meta.includes`
  dependencies, real hosts, and compatible build systems.
- `fast` parses changed Nix files, validates JSON, TOML, Python, and Agent Skill
  frontmatter, checks whitespace, and runs configured hooks only for the
  selected files.
- `eval` instantiates affected NixOS and nix-darwin configurations. Flake-wide,
  validation-tool, shell, overlay, and test changes additionally evaluate every
  flake system.
- `build` realizes affected configurations supported by the current platform
  with no result link. Incompatible targets remain evaluation-only until a
  matching runner handles them.
- `all` performs task-scoped file checks, all-system evaluation, and compatible
  targeted builds.
- `full` runs all-file hooks, all-system evaluation, and every check for the
  current platform through `nix-fast-build`.

The validation app constructs a filtered temporary `path:` flake from the
committed `HEAD` tree and overlays only task-owned changed paths. This isolates
unrelated worktree changes, makes new untracked Registry fragments visible to
Nix without staging them, and avoids copying ignored state such as `.direnv`.

None of these commands runs `nh os switch`, `nixos-rebuild switch`,
`darwin-rebuild switch`, `home-manager switch`, or another activation command.
The user performs activation separately.

## Agent Skills

Read `AGENTS.md` first. Use the repository skills as follows:

- `validate-nix-change` controls validation scope and evidence.
- `debug-nix-failure` classifies parse, evaluation, build, test, activation-log,
  and runtime failures before proposing a correction.
- `test-nixos-service` adds a `pkgs.testers.runNixOSTest` check when a build
  cannot prove service behavior.
- `update-flake-input` limits lock-file updates and validates them without
  activating a host.
- `add-application-or-service` preserves Registry ownership and delegates
  validation to `validate-nix-change`.

## MCP and language-server setup

The development workload installs `mcp-nixos`, `nixd`, `nix-fast-build`, and
`nix-tree`.

Project-local Codex and OpenCode configuration exposes:

- `mcp-nixos` for current NixOS, Home Manager, nix-darwin, package, and Nix
  documentation queries;
- GitHub's remote MCP endpoint for Codex and OpenCode in read-only mode,
  restricted to repository, pull-request, and Actions toolsets.

Set `GITHUB_PERSONAL_ACCESS_TOKEN` in the launching environment when GitHub MCP
access is needed. Do not commit the token or put it in a Nix expression because
that would expose it through source control or the Nix store.

The workspace VS Code settings use `nixd` and expose option sets for the
`galleria` NixOS configuration, its integrated Home Manager configuration, the
`m2` nix-darwin configuration, and its integrated Home Manager configuration.
