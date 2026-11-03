#!/bin/sh
set -eu

if [ "$#" -gt 1 ]; then
  echo "Usage: $0 [release-tag]" >&2
  exit 2
fi

release_tag=${1:-nvim-portable}
case "$release_tag" in
'' | *[!a-zA-Z0-9._-]*)
  echo "Invalid release tag: $release_tag" >&2
  exit 2
  ;;
esac

if [ "$(uname -s)" != Linux ]; then
  echo "This bundle supports Linux only." >&2
  exit 1
fi
case "$(uname -m)" in
x86_64 | amd64) arch=x86_64 ;;
aarch64 | arm64) arch=aarch64 ;;
*)
  echo "Unsupported CPU architecture: $(uname -m)" >&2
  exit 1
  ;;
esac

for command in curl sha256sum; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Missing $command. On Ubuntu: sudo apt install curl ca-certificates coreutils" >&2
    exit 1
  fi
done

install_dir=${MOONS_NVIM_INSTALL_DIR:-$HOME/.local/bin}
mkdir -p "$install_dir"
temp_dir=$(mktemp -d "$install_dir/.moons-nvim.XXXXXX")
trap 'rm -rf "$temp_dir"' EXIT
trap 'exit 1' HUP INT TERM

asset="moons-nvim-linux-$arch"
base_url="https://github.com/moons-14/dotfiles/releases/download/$release_tag"
curl --fail --location --retry 3 "$base_url/$asset" -o "$temp_dir/$asset"
curl --fail --location --retry 3 "$base_url/$asset.sha256" -o "$temp_dir/$asset.sha256"
(
  cd "$temp_dir"
  sha256sum --check "$asset.sha256"
)
chmod 0755 "$temp_dir/$asset"

target="$install_dir/moons-nvim"
if [ -e "$target" ] || [ -L "$target" ]; then
  cp -pL "$target" "$temp_dir/previous"
  mv -f "$temp_dir/previous" "$target.previous"
fi
mv -f "$temp_dir/$asset" "$target"

printf 'Installed %s from release %s\n' "$target" "$release_tag"
printf 'Run: %s path/to/file\n' "$target"
