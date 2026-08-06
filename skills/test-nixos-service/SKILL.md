---
name: test-nixos-service
description: Add or extend a non-activating NixOS VM or container test for service startup, sockets, timers, permissions, firewall behavior, reboot state, and inter-service dependencies. Use when evaluation and a system build cannot prove the requested runtime behavior.
---

# Test NixOS Runtime Behavior

Prefer `pkgs.testers.runNixOSTest` for reusable NixOS behavior that can be
proved without the user's physical machine. Do not activate the host
configuration and do not substitute a live `nh os switch` for a deterministic
test.

## Define the observable contract

List the runtime facts that must hold, such as:

- a systemd unit reaches `active`;
- a socket or port is listening;
- a timer triggers its service;
- a user can or cannot read a file;
- a group membership grants access;
- a firewall permits one path and blocks another;
- state survives a reboot;
- one service waits for another dependency.

Exclude behavior that requires physical GPU, fingerprint, audio, display,
Secure Boot, TPM, private credentials, or an external provider unless the test
can model it explicitly.

## Implement the smallest useful machine

Create a test under `tests/` and expose it through `checks.<system>`. Import the
owning module or Registry selection instead of copying its implementation into
the test. Use only the packages, users, files, and network peers required by the
contract.

Typical shape:

```nix
pkgs.testers.runNixOSTest {
  name = "service-name";

  nodes.machine = {
    # Enable the owning unit or import the module under test.
  };

  testScript = ''
    machine.start()
    machine.wait_for_unit("service-name.service")
    machine.succeed("systemctl is-active service-name.service")
  '';
}
```

Use `wait_for_unit`, `wait_for_open_port`, `succeed`, `fail`, and explicit
reboots to express outcomes. Avoid arbitrary sleeps when a readiness condition
exists.

## Validate and report

Run the targeted test through its flake check, then run the repository
validation app for the task paths. Report the test attribute and assertions
that passed. State clearly which hardware or external behavior remains outside
the VM/container model.
