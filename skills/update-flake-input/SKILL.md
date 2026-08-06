---
name: update-flake-input
description: Update one or more pinned flake inputs with bounded lock-file changes and non-activating Linux and Darwin validation. Use for dependency refreshes, input-specific updates, automated lock-file pull requests, or diagnosing a regression introduced by flake.lock.
---

# Update a Flake Input

Keep the update scope explicit and treat `flake.lock` as generated dependency
state. Never activate a host as part of this workflow; do not run `nh os switch`,
`nixos-rebuild switch`, `darwin-rebuild switch`, `home-manager switch`, or an
equivalent command.

## Bound the update

1. Read `AGENTS.md`, inspect `git status --short`, and preserve unrelated work.
2. Record the input names and the behavior or version change being requested.
3. Prefer an input-specific update:

```sh
nix flake update <input-name>
```

Use an unrestricted `nix flake update` only when the task explicitly requests a
full refresh. Do not hand-edit lock nodes.

## Audit the lock diff

Inspect the complete `flake.lock` diff. Confirm that changed nodes are the
requested inputs or unavoidable followers and that source owners, repositories,
reference types, and hashes remain expected. Investigate unexpected node
replacement, disappearing followers, or a large transitive graph rewrite before
validation.

## Validate without activation

Run the common validation workflow against the lock file:

```sh
nix run .#check -- plan --paths flake.lock --json
nix run .#check -- fast --paths flake.lock
nix run .#check -- eval --paths flake.lock
nix run .#check -- build --paths flake.lock
```

A lock-file change requires full evaluation and the complete native check set.
Linux and Darwin builds must run on compatible runners. The scheduled update
workflow uploads the candidate lock file, builds Linux and Darwin checks, and
creates a pull request only after both pass.

When a failure appears only after the update, invoke `debug-nix-failure`, compare
the failing derivation or option with the base lock, and narrow the responsible
input before adding an override or patch.

## Report the result

List requested and transitively changed inputs, validation commands and native
platform results, any package or option migration, and remaining manual runtime
checks. Evaluation or a native build is not activation.
