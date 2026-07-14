# Gitea Release-backed Nix binary cache

The workflows in `.gitea/workflows/` publish the closures of every
`nixosConfigurations` host to Gitea Releases.

- `nix-cache-bootstrap.yml` is a one-shot manual workflow that creates the
  initial cache.
- `nix-cache-update.yml` runs on every branch push. It creates one immutable
  generation release per commit and uploads only NAR content hashes that have
  not appeared in an older generation.
- Hosts are built independently. If one host fails, successful host closures
  and store paths completed during the failed build are published before the
  job reports the build failure.
- The `cache-latest` release is the stable cache index. It contains
  `nix-cache-info`, `cache-public-key`, `cache-manifest.json`, and every
  `<store-hash>.narinfo` file.
- Each narinfo has an absolute `URL:` that points at the generation release
  containing its immutable NAR. Rewriting `URL:` does not alter the signed
  store-path fingerprint.

The operational manifest enumerates all narinfo and NAR URLs. Nix itself does
not read that manifest: it requests `nix-cache-info` and
`<store-hash>.narinfo` directly from the cache URI.

## One-time setup

Generate a signing key on a trusted machine:

```sh
umask 077
nix key generate-secret --key-name dotfiles-gitea-cache-1 > cache-private-key
nix key convert-secret-to-public < cache-private-key
```

Add the complete contents of `cache-private-key` as the repository Actions
secret `NIX_CACHE_PRIVATE_KEY`. Do not commit this file. Ensure the repository
Actions token is allowed to write Releases, then run **Bootstrap Nix binary
cache** once from the Actions UI.

The bootstrap log and the following stable asset expose the public key:

```text
https://git.yutakobayashi.com/moons-14/dotfiles/releases/download/cache-latest/cache-public-key
```

The repository and its Release assets must be publicly readable for ordinary
Nix clients to use this as an unauthenticated substituter. The runner needs
enough disk for the Nix store plus one compressed copy of all host closures.
It also needs `bash`, `curl`, `jq`, and standard GNU userland tools.

The workflows remove `/homeless-shelter` before building. Nix requires that
dummy home path not to exist when the runner performs builds without a sandbox.

## Large release assets and Cloudflare

`git.yutakobayashi.com` is proxied by Cloudflare. Large NAR uploads can receive
`413 Request Entity Too Large` before they reach Gitea. NAR files cannot be
split because the Nix binary-cache protocol downloads each NAR as one object.

Create an HTTPS origin hostname that is DNS-only in Cloudflare, or use a
private Gitea URL reachable from the runner. Set that URL as the repository
Actions variable `NIX_CACHE_API_SERVER_URL`, for example:

```text
https://git-origin.yutakobayashi.com
```

Only Gitea API calls and uploads use this variable. `CACHE_SERVER_URL` remains
the public URL, so the URLs written to narinfo and the client substituter stay
under `https://git.yutakobayashi.com`.

The origin reverse proxy request-body limit and Gitea's
`[repository.release] FILE_MAX_SIZE` must also be larger than the largest NAR.
Protect an origin hostname with a firewall or another access control that still
allows the Actions runner to reach it.

When server-side limits cannot be changed, the workflows enforce
`CACHE_MAX_UPLOAD_BYTES=90000000`. NARs larger than that limit and their
narinfo files are not uploaded. They are recorded under `skipped` in
`cache-manifest.json`. Nix clients can still substitute every smaller store
path and obtain a skipped path from another substituter or build it locally.
Set the value to `0` only when the upload path has no smaller request limit.

## NixOS client configuration

After bootstrap, copy the exact value from `cache-public-key` into
`extra-trusted-public-keys`:

```nix
{
  nix.settings = {
    extra-substituters = [
      "https://git.yutakobayashi.com/moons-14/dotfiles/releases/download/cache-latest"
    ];
    extra-trusted-public-keys = [
      "dotfiles-gitea-cache-1:REPLACE_WITH_THE_GENERATED_PUBLIC_KEY"
    ];
  };
}
```

The substituter value is the directory-like cache URI, not the manifest file
URL. A quick validation after bootstrap is:

```sh
cache=https://git.yutakobayashi.com/moons-14/dotfiles/releases/download/cache-latest
curl --fail "$cache/nix-cache-info"
curl --fail "$cache/cache-manifest.json" | jq '.cache, (.objects | length), (.narinfos | length)'
```

Because every branch receives the signing secret, only trusted users should be
allowed to push branches or modify Actions workflows in this repository.
