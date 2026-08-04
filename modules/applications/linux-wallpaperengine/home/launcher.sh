# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

playlist_file="$1"
default_id="$2"
configuration_id="$3"
assets_dir="$4"
workshop_dir="$5"
scaling="$6"
shift 6

state_file="${XDG_RUNTIME_DIR:?}/linux-wallpaperengine/current"
wallpaper_id="$default_id"
saved_configuration=""
saved_id=""
saved_state=()
outputs=()

if [ -s "$state_file" ]; then
  mapfile -t saved_state <"$state_file"
  saved_configuration="${saved_state[0]:-}"
  saved_id="${saved_state[1]:-}"

  if [ "$saved_configuration" = "$configuration_id" ] &&
    awk -v id="$saved_id" '$0 == id { found = 1 } END { exit !found }' "$playlist_file"; then
    wallpaper_id="$saved_id"
  fi
fi

wallpaper_path="$workshop_dir/$wallpaper_id"
if [ ! -d "$wallpaper_path" ]; then
  echo "linux-wallpaperengine: missing declared wallpaper: $wallpaper_path" >&2
  exit 1
fi

if [ ! -d "$assets_dir" ]; then
  echo "linux-wallpaperengine: missing Wallpaper Engine assets: $assets_dir" >&2
  exit 1
fi

mapfile -t outputs < <(wlr-randr --json | jq -r '.[] | select(.enabled == true) | .name')
if [ "${#outputs[@]}" -eq 0 ]; then
  echo "linux-wallpaperengine: no enabled Wayland outputs were detected" >&2
  exit 1
fi

engine_args=("$@" --assets-dir "$assets_dir")
for output in "${outputs[@]}"; do
  engine_args+=(
    --screen-root "$output"
    --bg "$wallpaper_path"
    --scaling "$scaling"
  )
done

exec linux-wallpaperengine "${engine_args[@]}"
