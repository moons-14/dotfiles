# nix-builder bootstrap

The host configuration can be built before its cache signing secret exists.
Harmonia's socket remains stopped until SOPS installs the signing key at
`/run/secrets/harmonia/signing-key`.

## Proxmox storage layout

The host configuration expects three filesystems. Keep the build scratch space
separate from the store so a large build cannot fill the root filesystem.

| Mount point          | Suggested size | Contents                        |
| -------------------- | -------------- | ------------------------------- |
| `/`                  | 48 GiB         | NixOS and mutable system state  |
| `/var/lib/nix-build` | 192 GiB        | Disposable build scratch space  |
| `/nix/store`         | 1 TiB          | Fleet closures and binary cache |

The build-server policy starts emergency store GC below 64 GiB free and aims
for 128 GiB free. Persistent roots under `/var/lib/nix-fleet/roots` protect the
latest fleet builds from that GC. It also limits Nix to two concurrent
derivations while allowing each derivation to use every vCPU assigned to the
VM.

For the two dedicated ext4 data filesystems, remove the default root-reserved
blocks once after formatting; keep the root filesystem's reserve intact:

```bash
sudo tune2fs -m 0 /dev/disk/by-label/nix-build
sudo tune2fs -m 0 /dev/disk/by-label/nix-store
```

## Initial deployment

Once the VM is reachable as `moons@nix-builder`, deploy it from the repository:

```bash
nix run .#deploy -- .#nix-builder
```

deploy-rs uses the target's `ssh-ng` store, so the system closure is built on
the builder rather than copied from the laptop. Automatic and magic rollback
remain enabled.

## Add the host SOPS recipient

After the VM has a stable SSH host key, derive its age recipient:

```bash
ssh-keyscan -t ed25519 nix-builder 2>/dev/null | ssh-to-age
```

Add the recipient to `.sops.yaml` and add a creation rule for
`secrets/hosts/nix-builder/*.yaml`. The admin YubiKey recipient should remain in
the same key group for recovery.

## Generate the cache signing key

Run this on a trusted Nix machine, preferably with the temporary files on a
tmpfs:

```bash
nix-store --generate-binary-cache-key \
  cache.app.homelabs.run-1 \
  harmonia.private \
  harmonia.public
```

Create `secrets/hosts/nix-builder/system.yaml` with SOPS and store the complete
contents of `harmonia.private` at `harmonia.signing-key`:

```yaml
harmonia:
  signing-key: cache.app.homelabs.run-1:REDACTED
```

Copy the complete contents of `harmonia.public` to
`modules/systems/nix/homelab-cache/public-key`. The private plaintext file must
not be committed or retained.

After committing both encrypted/public files, select
`networking.homelab-cache-client` on each client host.

Redeploy the builder and verify the cache after installing the secret:

```bash
nix run .#deploy -- .#nix-builder
curl --fail http://nix-builder:5000/nix-cache-info
```

## Normal operation

Run `fleet-build` on the builder to build and root every NixOS host, or pass a
list of host names to build only those hosts. Run `fleet-deploy` with the normal
deploy-rs target syntax when additional fleet nodes have been added to
`flake/deploy.nix`:

```bash
fleet-build
fleet-build x1g13 galleria
fleet-deploy .#nix-builder
```
