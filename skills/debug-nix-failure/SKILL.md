---
name: debug-nix-failure
description: Diagnose failures from parsing, Nix module evaluation, derivation builds, flake checks, NixOS tests, or Home Manager activation logs without changing the live system. Use when `nix run .#check`, `nix flake check`, `nix build`, CI, or a user-provided activation log fails.
---

# Debug a Nix Failure

Classify the failure before changing code. Preserve the original command,
complete error, first causal frame, and affected attribute. Never run a live
switch or activation to reproduce a validation failure.

## Identify the failing layer

- **Parse or format:** syntax location, malformed string, unmatched delimiter,
  or formatter-owned rewrite.
- **Static analysis:** dead binding, suspicious expression, ShellCheck finding,
  secret scan, or workflow lint.
- **Module evaluation:** missing option, wrong type, assertion, infinite
  recursion, conflicting definitions, Registry selection, or unsupported host
  class.
- **Derivation instantiation/build:** missing dependency, hash mismatch, patch
  failure, compiler/test failure, sandbox violation, or unsupported platform.
- **NixOS test:** failed unit, timeout, command assertion, network readiness, or
  reboot state.
- **Activation/runtime:** filesystem conflict, activation script, systemd unit,
  hardware, credential, or external-service behavior. Diagnose only from logs
  supplied by the user unless they explicitly request a non-switch inspection
  command.

## Reproduce the narrowest failing operation

Start with the stage and paths reported by the validation app:

```sh
nix run .#check -- plan --paths <task-path>... --json
nix run .#check -- fast --paths <task-path>...
nix run .#check -- eval --paths <task-path>...
nix run .#check -- build --paths <task-path>...
```

For a single attribute, use `nix eval --show-trace` on its `drvPath` before a
build. For a failed derivation, retain `--print-build-logs` and inspect
`nix log <drv-path>` when the summary omits the causal lines.

## Read traces selectively

1. Find the first repository-owned frame or option path.
2. Separate the immediate failure from wrapper frames in `modules.nix`,
   `lib.evalModules`, or flake-parts.
3. Inspect the option declaration and every definition contributing to it.
4. Confirm package and option names against locked inputs, not memory.
5. Check whether the failure reproduces on the base revision before calling it
   task-owned.

Do not respond to a type or ownership error with import-order changes,
`lib.mkForce`, global arguments, or an overlay unless repository evidence shows
that those mechanisms are the correct owner.

## Finish with a bounded diagnosis

Report the failing layer, root cause, minimal correction, rerun command, and any
remaining platform or runtime gap. Include enough of the error to identify it,
but do not paste large unrelated logs.
