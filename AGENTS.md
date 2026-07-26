# Repository Guidelines

## Project Structure & Module Organization

This repository manages NixOS and Home Manager configuration as a flake. `flake.nix` defines inputs and imports the project modules. Keep flake-level plumbing in `flake/`, reusable package overlays in `overlays/`, and development environments in `shells/`. Add configuration under the appropriate `modules/` category: `applications/`, `hardwares/`, `profiles/`, `services/`, `systems/`, or `users/`. Keep host- or user-specific choices near their owning module rather than in the root flake.

## Build, Test, and Development Commands

- `nix develop .#dotnix` enters the main development shell and installs the repository's pre-commit hooks.
- `nix develop .#android` provides Android platform tools such as `adb` and `fastboot`.
- `nix fmt` formats all supported files through treefmt.
- `nix flake check` evaluates flake outputs and runs configured checks.
- `pre-commit run --all-files` runs formatting, dead-code and static Nix checks, shell linting, and secret scanning.
- `nix flake update` refreshes pinned inputs in `flake.lock`; review lockfile changes before committing.

If direnv is installed, `direnv allow` activates the `dotnix` shell from `.envrc` automatically.

## Coding Style & Naming Conventions

Use two-space indentation in Nix files and let `nixfmt` decide layout. Prefer small modules with explicit imports and descriptive kebab-case filenames, for example `modules/services/media-server.nix`. Use camelCase for Nix attributes unless an upstream option dictates otherwise. Shell snippets must pass `shfmt` and `shellcheck`; YAML, TOML, and Markdown are formatted by the configured treefmt tools.

## Testing Guidelines

There is no separate unit-test suite. Before submitting changes, run `nix flake check` and `pre-commit run --all-files`. For system-specific changes, also build or evaluate the affected NixOS/Home Manager configuration without switching the live machine. Never commit generated secrets, `.age` plaintext, or local `.direnv/` state.

## Commit & Pull Request Guidelines

Recent history favors short, lowercase, imperative subjects such as `fix` and `update action`; automated dependency commits use `chore(deps): ...`. Prefer a specific summary that states the affected area, such as `shells: add deployment tools`. Keep commits focused. Pull requests should explain the motivation, list affected hosts or profiles, report validation commands, and note any manual migration or secret-management steps. Include screenshots only for visible desktop or application configuration changes.
