# shellcheck shell=bash

set -o errexit -o nounset -o pipefail

playlist_file="$1"
default_id="$2"
configuration_id="$3"
shift 3

state_dir="${XDG_RUNTIME_DIR:?}/linux-wallpaperengine"
state_file="$state_dir/current"

usage() {
  printf '%s\n' \
    'Usage: wallpaperengine-wallpaper COMMAND [ID]' \
    '' \
    'Commands:' \
    '  select ID Select a declaratively configured ID for this session' \
    '  next      Select the next configured ID' \
    '  previous  Select the previous configured ID' \
    '  list      List configured IDs and mark the selected one' \
    '  current   Print the selected ID' \
    '  restart   Restart the selected wallpaper' \
    '  stop      Stop Wallpaper Engine for this session'
}

load_playlist() {
  mapfile -t wallpaper_ids < <(awk '/^[0-9]+$/ && !seen[$0]++' "$playlist_file")
  if [ "${#wallpaper_ids[@]}" -eq 0 ]; then
    echo "wallpaperengine-wallpaper: no wallpaper IDs are configured in settings.nix" >&2
    exit 1
  fi
}

contains_id() {
  local candidate="$1"
  local id

  for id in "${wallpaper_ids[@]}"; do
    [ "$id" = "$candidate" ] && return 0
  done
  return 1
}

current_id() {
  local saved_configuration=""
  local saved_id=""
  local -a saved_state=()

  if [ -s "$state_file" ]; then
    mapfile -t saved_state <"$state_file"
    saved_configuration="${saved_state[0]:-}"
    saved_id="${saved_state[1]:-}"
  fi

  if [ "$saved_configuration" = "$configuration_id" ] && contains_id "$saved_id"; then
    printf '%s\n' "$saved_id"
  else
    printf '%s\n' "$default_id"
  fi
}

select_id() {
  local id="$1"

  if ! contains_id "$id"; then
    echo "wallpaperengine-wallpaper: ID is not declared in settings.nix: $id" >&2
    exit 2
  fi

  mkdir -p "$state_dir"
  printf '%s\n%s\n' "$configuration_id" "$id" >"$state_file"
  systemctl --user restart linux-wallpaperengine.service
}

cycle() {
  local step="$1"
  local current
  local index=0
  local next_index

  current=$(current_id)
  for i in "${!wallpaper_ids[@]}"; do
    if [ "${wallpaper_ids[$i]}" = "$current" ]; then
      index="$i"
      break
    fi
  done

  next_index=$(((index + step + ${#wallpaper_ids[@]}) % ${#wallpaper_ids[@]}))
  select_id "${wallpaper_ids[$next_index]}"
}

load_playlist

command="${1:-}"
if [ -z "$command" ]; then
  usage
  exit 2
fi
shift

case "$command" in
select)
  [ "$#" -eq 1 ] || {
    usage >&2
    exit 2
  }
  select_id "$1"
  ;;
next)
  [ "$#" -eq 0 ] || {
    usage >&2
    exit 2
  }
  cycle 1
  ;;
previous)
  [ "$#" -eq 0 ] || {
    usage >&2
    exit 2
  }
  cycle -1
  ;;
list)
  [ "$#" -eq 0 ] || {
    usage >&2
    exit 2
  }
  current=$(current_id)
  for id in "${wallpaper_ids[@]}"; do
    if [ "$id" = "$current" ]; then
      printf '* %s\n' "$id"
    else
      printf '  %s\n' "$id"
    fi
  done
  ;;
current)
  [ "$#" -eq 0 ] || {
    usage >&2
    exit 2
  }
  current_id
  ;;
restart)
  [ "$#" -eq 0 ] || {
    usage >&2
    exit 2
  }
  systemctl --user restart linux-wallpaperengine.service
  ;;
stop)
  [ "$#" -eq 0 ] || {
    usage >&2
    exit 2
  }
  systemctl --user stop linux-wallpaperengine.service
  ;;
help | -h | --help)
  usage
  ;;
*)
  usage >&2
  exit 2
  ;;
esac
