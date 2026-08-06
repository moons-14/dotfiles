---
name: add-application-or-service
description: Add, install, configure, or enable an application or long-running service in this NixOS, nix-darwin, and Home Manager flake while preserving its Registry architecture and quality bar. Use for new GUI or CLI applications, packages, daemons, background services, application-service pairs, cross-platform installations, profile adoption, or substantial extensions to an existing application or service unit.
---

# Add Application or Service

Add the smallest complete Registry unit change that has a clear owner, an
explicit dependency path, and evidence that every affected host class
evaluates. Treat `AGENTS.md` as the authoritative repository contract; never
replace it with generic Nix conventions.

## Follow the workflow

### 1. Establish the baseline

1. Read `AGENTS.md` completely before editing.
2. Run `git status --short`. Preserve all pre-existing user changes and identify
   which later diffs belong to this task.
3. Translate the request into observable outcomes: package or program, desired
   configuration, supported host classes, required daemon or permissions, and
   the profile or user intent that should select it.
4. Inspect the nearest existing units, relevant profiles, `hosts/default.nix`,
   and Registry implementation. Prefer repository evidence over memory.
5. Verify current package names, module options, external module exports, and
   Homebrew cask names from the locked inputs or authoritative upstream
   documentation. Do not guess an option path.
6. Read [references/review-checklist.md](references/review-checklist.md) before
   choosing files or dependencies.

### 2. Choose ownership before code

Classify each concern independently:

- Put the user-facing program and its settings in
  `modules/applications/<name>/`.
- Put a daemon, long-running process, firewall rule, permission, or user/group
  membership in `modules/services/<name>/`.
- Split an application and independently meaningful daemon into two units.
  Let the application include the service only when the service is a technical
  requirement of that application.
- Put adoption of otherwise independent units in the narrowest coherent
  `modules/profiles/` composition.
- Use another documented owner when the request is actually a system,
  hardware, user, overlay, or host concern. Do not force it into an application
  or service directory merely because this skill was invoked.

Choose only the reserved fragments that contain real configuration. Use
`common.nix`, `nixos.nix`, and `darwin.nix` for system-side configuration; use
`home.nix` or `home/{common,nixos,darwin}.nix` for Home Manager. Use `meta.nix`
only for description, fully qualified `includes`, and external module imports.

Before editing, formulate a short implementation contract containing:

- the unit ID and owner;
- each file to create or change and why;
- technical dependencies versus profile-level choices;
- supported and affected host classes;
- the evaluations or builds that will prove the change.

Rework the design if an ordinary addition appears to require Registry changes,
new global `specialArgs`, `_module.args`, direct host selection, or an overlay.
Use those mechanisms only with concrete evidence that the documented extension
points cannot express the requirement.

### 3. Implement the minimum complete change

1. Return configuration directly from every reserved fragment. Do not add
   top-level `imports`, `options`, or `config`, and do not reproduce Registry
   `mkEnableOption`, `cfg`, or `mkIf` boilerplate.
2. Put upstream NixOS, nix-darwin, or Home Manager modules in
   `meta.imports.<class>`. Import ordinary helper files explicitly from the
   fragment that uses them.
3. Declare unit-to-unit technical dependencies only through fully qualified
   `meta.includes`. Never enable another unit by assigning its
   `my.<path>.enable` option inside a fragment.
4. Add an independent application or service to an existing coherent profile,
   or create a justified profile when no existing one expresses the user
   intent. Do not use `hosts/default.nix` application or unit escape hatches for
   normal composition.
5. Keep cross-platform purpose shared and installation differences in the
   owning unit. Do not create thin `*-linux` profiles.
6. Use existing module arguments and standard options. Do not inject a
   dependency through global arguments, Registry internals, import ordering, or
   `lib.mkForce`. Use explicit module priorities only when a real ownership
   boundary requires them and make that reason visible in the code or handoff.
7. Avoid speculative abstraction. Create a helper only when it separates
   meaningful configuration or prevents real duplication. Do not add empty
   fragments, compatibility aliases, unused options, redundant comments, or
   copied boilerplate.
8. Update `modules/profiles/README.md`, `AGENTS.md`, profile selections, or
   other contract documentation whenever the change makes an existing
   statement stale. Do not edit them performatively when their meaning remains
   accurate.

### 4. Prove the change

Invoke the `validate-nix-change` skill and use the task-owned files as its
explicit path set. At minimum:

1. Inspect `nix run .#check -- plan --paths <task-path>... --json` and confirm
   the reported units, host classes, and real hosts are correct.
2. Run `nix run .#check -- fast --paths <task-path>...` during the edit loop.
3. Inspect the complete task diff for accidental files, duplication, leaked
   secrets, forced values, direct enable assignments, and unrelated rewrites.
4. Run `nix run .#check -- all --paths <task-path>...` after the structure is
   complete. This evaluates every flake system and builds affected targets for
   the current platform without activation.
5. Verify selection as well as syntax: confirm that the expected package,
   program, service, group, cask, or external module appears in the resulting
   configuration.
6. Add a `pkgs.testers.runNixOSTest` check through the `test-nixos-service`
   skill when service startup or another runtime contract cannot be proved by
   evaluation and a system build.

Use `nix run .#check -- full` only for CI, scheduled maintenance, or an explicit
repository-wide audit. These commands never activate the live system. Do not
run `nh os switch`, `nixos-rebuild switch`, `darwin-rebuild switch`,
`home-manager switch`, or an equivalent activation command as validation.

If a command is unavailable, blocked by the environment, or fails for a
pre-existing reason, invoke the `debug-nix-failure` skill, diagnose it, and
report the exact gap. Never silently skip a required check or weaken the
implementation to make a check pass.

### 5. Audit before completion

Reject the change until all of the following are true:

- Every line has one clear owner and is required by the requested behavior.
- Every dependency is either technical and declared in `meta.includes`, or a
  user choice owned by a profile.
- The unit is reachable from the intended profile or has an explicit reason to
  remain independently selectable.
- No host, Registry, flake root, global argument, or overlay was changed as a
  shortcut.
- Reserved fragments, metadata, and profile documentation satisfy the current
  repository contract.
- Validation covers every affected host class and all failures are resolved or
  explicitly reported.

Conclude with the owner and selection rationale, affected hosts or profiles,
validation commands and results, and any manual activation or runtime check
that remains. Do not claim runtime behavior that was only evaluated.
