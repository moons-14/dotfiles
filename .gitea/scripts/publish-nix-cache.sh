#!/usr/bin/env bash
set -euo pipefail

# Gitea Releases are used as an append-only object store. The cache-latest
# release contains the HTTP binary-cache index, while generation releases
# contain immutable NAR payloads.

mode=${CACHE_MODE:-}
server_url=${CACHE_SERVER_URL:-}
api_server_url=${CACHE_API_SERVER_URL:-}
repository=${CACHE_REPOSITORY:-}
commit=${CACHE_COMMIT:-}
ref_name=${CACHE_REF_NAME:-unknown}
index_tag=${CACHE_INDEX_TAG:-cache-latest}
generation_prefix=${CACHE_GENERATION_PREFIX:-nix-cache-generation-}
upload_jobs=${CACHE_UPLOAD_JOBS:-4}
max_upload_bytes=${CACHE_MAX_UPLOAD_BYTES:-}
key_file=${NIX_CACHE_KEY_FILE:-}
api_is_internal=0
api_curl_options=()

for command in curl jq nix awk comm sed find sort; do
  if ! command -v "$command" >/dev/null 2>&1; then
    echo "Required command is unavailable: $command" >&2
    exit 1
  fi
done

if [[ $mode != bootstrap && $mode != update ]]; then
  echo "CACHE_MODE must be either 'bootstrap' or 'update'." >&2
  exit 1
fi

if [[ -z $server_url || -z $repository || -z $commit ]]; then
  echo "CACHE_SERVER_URL, CACHE_REPOSITORY, and CACHE_COMMIT are required." >&2
  exit 1
fi

if [[ -z ${GITEA_TOKEN:-} ]]; then
  echo "GITEA_TOKEN is required." >&2
  exit 1
fi

if [[ ! -s $key_file ]]; then
  echo "NIX_CACHE_KEY_FILE must point to a non-empty signing key." >&2
  exit 1
fi

if [[ ! $upload_jobs =~ ^[1-9][0-9]*$ ]]; then
  echo "CACHE_UPLOAD_JOBS must be a positive integer." >&2
  exit 1
fi

if [[ -n $max_upload_bytes && ! $max_upload_bytes =~ ^[0-9]+$ ]]; then
  echo "CACHE_MAX_UPLOAD_BYTES must be zero or a positive integer." >&2
  exit 1
fi

server_url=${server_url%/}
api_server_url=${api_server_url:-$server_url}
api_server_url=${api_server_url%/}
api_base="${api_server_url}/api/v1/repos/${repository}"
download_base="${server_url}/${repository}/releases/download"
cache_uri="${download_base}/${index_tag}"
manifest_url="${cache_uri}/cache-manifest.json"
public_key_url="${cache_uri}/cache-public-key"
public_key=$(nix key convert-secret-to-public <"$key_file")
key_name=${public_key%%:*}

work_dir=$(mktemp -d "${RUNNER_TEMP:-/tmp}/nix-release-cache.XXXXXX")
cache_dir="${work_dir}/cache"
rewritten_dir="${work_dir}/narinfo"
manifest_file="${work_dir}/manifest.json"
all_releases_file="${work_dir}/all-releases.json"
generation_release_file="${work_dir}/generation-release.json"
object_updates_file="${work_dir}/object-updates.jsonl"
narinfo_updates_file="${work_dir}/narinfo-updates.jsonl"
skipped_updates_file="${work_dir}/skipped-updates.jsonl"
nar_upload_queue="${work_dir}/nar-upload-queue"
narinfo_upload_queue="${work_dir}/narinfo-upload-queue"
mkdir -p "$cache_dir" "$rewritten_dir"
: >"$object_updates_file"
: >"$narinfo_updates_file"
: >"$skipped_updates_file"
: >"$nar_upload_queue"
: >"$narinfo_upload_queue"
trap 'rm -rf "$work_dir"' EXIT

api_request() {
  local method=$1
  local path=$2
  shift 2

  curl "${api_curl_options[@]}" --fail-with-body --silent --show-error \
    --retry 5 --retry-delay 2 --retry-all-errors \
    --request "$method" \
    --header "Authorization: token ${GITEA_TOKEN}" \
    --header "Accept: application/json" \
    "$@" \
    "${api_base}${path}"
}

api_get_optional() {
  local path=$1
  local output=$2
  local status

  status=$(curl "${api_curl_options[@]}" --silent --show-error \
    --retry 5 --retry-delay 2 --retry-all-errors \
    --output "$output" --write-out '%{http_code}' \
    --header "Authorization: token ${GITEA_TOKEN}" \
    --header "Accept: application/json" \
    "${api_base}${path}")

  case "$status" in
  200)
    return 0
    ;;
  404)
    rm -f "$output"
    return 1
    ;;
  *)
    echo "Gitea API request failed with HTTP ${status}: ${path}" >&2
    cat "$output" >&2
    return 2
    ;;
  esac
}

create_release() {
  local tag=$1
  local name=$2
  local body=$3
  local prerelease=$4

  jq -n \
    --arg tag "$tag" \
    --arg name "$name" \
    --arg body "$body" \
    --arg target "$commit" \
    --argjson prerelease "$prerelease" \
    '{
      tag_name: $tag,
      target_commitish: $target,
      name: $name,
      body: $body,
      draft: false,
      prerelease: $prerelease
    }' | api_request POST /releases \
    --header 'Content-Type: application/json' \
    --data-binary @-
}

delete_asset() {
  local release_id=$1
  local asset_id=$2
  api_request DELETE "/releases/${release_id}/assets/${asset_id}" >/dev/null
}

upload_asset() {
  local release_id=$1
  local file=$2
  local name=$3
  local response_file
  local status
  local curl_status
  local size
  local size_mib

  response_file=$(mktemp "${work_dir}/upload-response.XXXXXX")
  size=$(stat -c '%s' "$file")
  size_mib=$(((size + 1048575) / 1048576))

  if status=$(curl "${api_curl_options[@]}" --silent --show-error \
    --retry 5 --retry-delay 2 --retry-all-errors \
    --request POST \
    --header "Authorization: token ${GITEA_TOKEN}" \
    --form "attachment=@${file};type=application/octet-stream" \
    --output "$response_file" --write-out '%{http_code}' \
    "${api_base}/releases/${release_id}/assets?name=${name}"); then
    curl_status=0
  else
    curl_status=$?
  fi

  if [[ $status == 200 || $status == 201 ]]; then
    rm -f "$response_file"
    return 0
  fi

  echo "Asset upload failed: name=${name} size=${size}B (${size_mib}MiB) HTTP=${status:-000} curl=${curl_status}" >&2
  if [[ $status == 413 ]]; then
    echo "The upload endpoint rejected this NAR as too large. Set the Gitea Actions variable NIX_CACHE_API_SERVER_URL to an origin URL that bypasses Cloudflare, and verify the origin proxy and Gitea release size limits." >&2
  fi
  sed -n '1,20p' "$response_file" >&2
  rm -f "$response_file"
  return 1
}

upload_asset_response() {
  local release_id=$1
  local file=$2
  local name=$3

  curl "${api_curl_options[@]}" --fail-with-body --silent --show-error \
    --retry 5 --retry-delay 2 --retry-all-errors \
    --request POST \
    --header "Authorization: token ${GITEA_TOKEN}" \
    --form "attachment=@${file};type=application/octet-stream" \
    "${api_base}/releases/${release_id}/assets?name=${name}"
}

rename_asset() {
  local release_id=$1
  local asset_id=$2
  local name=$3

  jq -n --arg name "$name" '{name: $name}' | api_request PATCH \
    "/releases/${release_id}/assets/${asset_id}" \
    --header 'Content-Type: application/json' \
    --data-binary @- >/dev/null
}

upload_queue() {
  local release_id=$1
  local queue_file=$2
  local file
  local name
  local pid
  local failed=0
  local -a pids=()

  if [[ ! -s $queue_file ]]; then
    return
  fi

  while IFS=$'\t' read -r file name; do
    upload_asset "$release_id" "$file" "$name" &
    pids+=("$!")

    if ((${#pids[@]} == upload_jobs)); then
      for pid in "${pids[@]}"; do
        if ! wait "$pid"; then
          failed=1
        fi
      done
      pids=()
    fi
  done <"$queue_file"

  for pid in "${pids[@]}"; do
    if ! wait "$pid"; then
      failed=1
    fi
  done
  if ((failed)); then
    return 1
  fi
}

list_all_releases() {
  local page=1
  local page_file="${work_dir}/releases-page.json"
  local releases_jsonl="${work_dir}/releases.jsonl"
  local count
  : >"$releases_jsonl"

  while :; do
    api_request GET "/releases?draft=false&pre-release=true&limit=50&page=${page}" >"$page_file"
    count=$(jq 'length' "$page_file")
    if ((count == 0)); then
      break
    fi
    jq -c '.[]' "$page_file" >>"$releases_jsonl"
    ((page += 1))
  done

  jq -s '.' "$releases_jsonl" >"$all_releases_file"
}

configure_api_transport() {
  local candidate
  local candidate_url
  local public_authority
  local version_json

  if [[ -n ${CACHE_API_SERVER_URL:-} ]]; then
    api_is_internal=1
    echo "Using configured Gitea origin API: ${api_server_url}"
  elif [[ $server_url == https://* ]]; then
    public_authority=${server_url#https://}
    public_authority=${public_authority%%/*}

    for candidate in host.containers.internal host.docker.internal; do
      if version_json=$(curl --silent --show-error \
        --noproxy '*' --connect-timeout 3 --max-time 5 \
        --connect-to "${public_authority}:443:${candidate}:443" \
        "${server_url}/api/v1/version" 2>/dev/null) &&
        jq -e '.version | type == "string"' <<<"$version_json" >/dev/null; then
        api_curl_options=(
          --noproxy '*'
          --connect-to "${public_authority}:443:${candidate}:443"
        )
        api_is_internal=1
        echo "Using direct Gitea HTTPS transport through ${candidate}:443; Cloudflare is bypassed."
        break
      fi
    done

    if ((api_is_internal == 0)); then
      for candidate in host.containers.internal host.docker.internal; do
        candidate_url="http://${candidate}:3000"
        if version_json=$(curl --silent --show-error \
          --noproxy '*' --connect-timeout 3 --max-time 5 \
          "${candidate_url}/api/v1/version" 2>/dev/null) &&
          jq -e '.version | type == "string"' <<<"$version_json" >/dev/null; then
          api_server_url=$candidate_url
          api_base="${api_server_url}/api/v1/repos/${repository}"
          api_curl_options=(--noproxy '*')
          api_is_internal=1
          echo "Using direct Gitea API through ${candidate}:3000; Cloudflare is bypassed."
          break
        fi
      done
    fi
  fi

  if [[ -z $max_upload_bytes ]]; then
    if ((api_is_internal)); then
      max_upload_bytes=0
      echo "No workflow-side NAR size limit is applied on the internal API transport."
    else
      max_upload_bytes=90000000
      echo "No internal Gitea API was reachable; using the public endpoint and limiting NAR uploads to ${max_upload_bytes} bytes."
    fi
  fi
}

initialize_manifest() {
  jq -n \
    --arg uri "$cache_uri" \
    --arg manifest "$manifest_url" \
    --arg public_key "$public_key" \
    --arg public_key_url "$public_key_url" \
    '{
      schemaVersion: 1,
      cache: {
        uri: $uri,
        nixCacheInfo: ($uri + "/nix-cache-info"),
        manifest: $manifest,
        publicKey: $public_key,
        publicKeyUrl: $public_key_url
      },
      generatedAt: null,
      generations: [],
      objects: {},
      narinfos: {},
      skipped: {}
    }' >"$manifest_file"
}

configure_api_transport

index_release_file="${work_dir}/index-release.json"
if api_get_optional "/releases/tags/${index_tag}" "$index_release_file"; then
  if [[ $mode == bootstrap ]]; then
    if jq -e '.assets[]? | select(.name == "cache-manifest.json")' \
      "$index_release_file" >/dev/null; then
      echo "Release '${index_tag}' is already bootstrapped." >&2
      exit 1
    fi
    echo "Resuming an interrupted cache bootstrap."
    initialize_manifest
  else
    manifest_asset_url=$(jq -r '
      [
        .assets[]?
        | select(.name == "cache-manifest.json")
      ]
      | last
      | .browser_download_url // empty
    ' "$index_release_file")
    if [[ -z $manifest_asset_url ]]; then
      manifest_asset_url=$(jq -r '
        [
          .assets[]?
          | select(.name | test("^cache-manifest-[0-9a-f]+\\.json$"))
        ]
        | sort_by(.created_at)
        | last
        | .browser_download_url // empty
      ' "$index_release_file")
      if [[ -z $manifest_asset_url ]]; then
        echo "The cache index has no recoverable manifest." >&2
        exit 1
      fi
      echo "Recovering the cache index from a temporary manifest."
    fi

    curl --fail-with-body --silent --show-error \
      --retry 5 --retry-delay 2 --retry-all-errors \
      --header "Authorization: token ${GITEA_TOKEN}" \
      --output "$manifest_file" \
      "$manifest_asset_url"

    if ! jq -e --arg public_key "$public_key" \
      '.schemaVersion == 1 and .cache.publicKey == $public_key' \
      "$manifest_file" >/dev/null; then
      echo "The cache manifest is invalid or was signed by a different key." >&2
      exit 1
    fi
  fi
else
  optional_status=$?
  if ((optional_status != 1)); then
    exit "$optional_status"
  fi

  if [[ $mode == update ]]; then
    echo "Release '${index_tag}' is missing. Run the bootstrap workflow first." >&2
    exit 1
  fi

  create_release \
    "$index_tag" \
    "Nix binary cache index" \
    "Stable HTTP index for the release-backed Nix binary cache." \
    false >"$index_release_file"
  initialize_manifest
fi

index_release_id=$(jq -r '.id' "$index_release_file")
if [[ -z $index_release_id || $index_release_id == null ]]; then
  echo "Could not determine the cache index release ID." >&2
  exit 1
fi

store_paths_before_file="${work_dir}/store-paths-before"
store_paths_after_file="${work_dir}/store-paths-after"
new_store_paths_file="${work_dir}/new-store-paths"
echo "Recording the Nix store state before evaluation and builds..."
nix path-info --all | sort -u >"$store_paths_before_file"

echo "Evaluating NixOS hosts..."
hosts_file="${work_dir}/hosts"
nix eval --json '.#nixosConfigurations' \
  --apply 'configs: builtins.attrNames configs' | jq -r '.[]' >"$hosts_file"
mapfile -t hosts <"$hosts_file"

if ((${#hosts[@]} == 0)); then
  echo "No NixOS configurations were discovered." >&2
  exit 1
fi

echo "Building hosts: ${hosts[*]}"
roots_file="${work_dir}/roots"
: >"$roots_file"
failed_hosts=()
for host in "${hosts[@]}"; do
  host_roots_file="${work_dir}/roots-${host}"
  echo "Building host: ${host}"
  if nix build --no-link --print-out-paths --print-build-logs \
    ".#nixosConfigurations.${host}.config.system.build.toplevel" |
    sort -u >"$host_roots_file"; then
    cat "$host_roots_file" >>"$roots_file"
  else
    echo "Host build failed; completed store paths will still be published: ${host}" >&2
    failed_hosts+=("$host")
  fi
done
sort -u -o "$roots_file" "$roots_file"

echo "Recording store paths completed during this job..."
nix path-info --all | sort -u >"$store_paths_after_file"
comm -13 "$store_paths_before_file" "$store_paths_after_file" >"$new_store_paths_file"

export_paths_file="${work_dir}/export-paths"
cat "$roots_file" "$new_store_paths_file" | sort -u >"$export_paths_file"
if [[ ! -s $export_paths_file ]]; then
  echo "No successfully completed store paths are available to publish." >&2
  exit 1
fi

successful_root_count=$(wc -l <"$roots_file")
new_store_path_count=$(wc -l <"$new_store_paths_file")
echo "Exporting ${successful_root_count} successful host roots and ${new_store_path_count} newly completed store paths..."
nix copy \
  --to "file://${cache_dir}?compression=zstd&compression-level=6&secret-key=${key_file}" \
  --stdin <"$export_paths_file"

first_narinfo=$(find "$cache_dir" -maxdepth 1 -type f -name '*.narinfo' -print -quit)
if [[ -z $first_narinfo ]] || ! grep -Fq "Sig: ${key_name}:" "$first_narinfo"; then
  echo "Generated narinfo files do not contain the expected cache signature." >&2
  exit 1
fi

list_all_releases

# Recover immutable NAR objects left by an interrupted older run. A NAR asset's
# content-addressed filename is globally unique, so it can be reused safely.
discovered_objects_file="${work_dir}/discovered-objects.json"
jq --arg prefix "$generation_prefix" '
  reduce (
    .[]
    | select(.tag_name | startswith($prefix)) as $release
    | $release.assets[]?
    | select(.name | test("\\.nar\\.(zst|xz|bz2|gz)$"))
    | {
        key: .name,
        value: {
          url: .browser_download_url,
          generation: $release.tag_name,
          size: .size
        }
      }
  ) as $object ({}; .[$object.key] //= $object.value)
' "$all_releases_file" >"$discovered_objects_file"

jq --slurpfile discovered "$discovered_objects_file" \
  '.objects = ($discovered[0] + .objects)' \
  "$manifest_file" >"${manifest_file}.new"
mv "${manifest_file}.new" "$manifest_file"

generation_tag="${generation_prefix}${commit}"
if api_get_optional "/releases/tags/${generation_tag}" "$generation_release_file"; then
  echo "Resuming generation release '${generation_tag}'."
else
  optional_status=$?
  if ((optional_status != 1)); then
    exit "$optional_status"
  fi

  create_release \
    "$generation_tag" \
    "Nix cache ${commit:0:12}" \
    "Branch: ${ref_name}\nCommit: ${commit}\nMode: ${mode}\nFailed hosts: ${failed_hosts[*]:-none}" \
    true >"$generation_release_file"
fi
generation_release_id=$(jq -r '.id' "$generation_release_file")

declare -A known_narinfos=()
declare -A object_urls=()
declare -A object_sizes=()
declare -A queued_objects=()
declare -A index_asset_ids=()

while IFS= read -r hash; do
  known_narinfos["$hash"]=1
done < <(jq -r '.narinfos | keys[]' "$manifest_file")

while IFS=$'\t' read -r name url; do
  object_urls["$name"]=$url
done < <(
  jq -r '.objects | to_entries[] | [.key, .value.url] | @tsv' \
    "$manifest_file"
)

while IFS=$'\t' read -r name id; do
  index_asset_ids["$name"]=$id
done < <(jq -r '.assets[]? | [.name, (.id | tostring)] | @tsv' "$index_release_file")

new_nar_count=0
new_narinfo_count=0
skipped_path_count=0
while IFS= read -r -d '' narinfo_file; do
  narinfo_name=$(basename "$narinfo_file")
  store_hash=${narinfo_name%.narinfo}

  if [[ -n ${known_narinfos[$store_hash]:-} ]]; then
    continue
  fi

  nar_relative=$(sed -n 's/^URL: //p' "$narinfo_file")
  store_path=$(sed -n 's/^StorePath: //p' "$narinfo_file")
  if [[ $nar_relative != nar/* || -z $store_path ]]; then
    echo "Malformed narinfo file: ${narinfo_file}" >&2
    exit 1
  fi

  nar_name=${nar_relative#nar/}
  nar_file="${cache_dir}/${nar_relative}"
  if [[ ! -f $nar_file ]]; then
    echo "NAR payload is missing: ${nar_file}" >&2
    exit 1
  fi

  if [[ -z ${object_urls[$nar_name]:-} ]]; then
    object_sizes["$nar_name"]=$(stat -c '%s' "$nar_file")
    nar_size=${object_sizes[$nar_name]}

    if ((max_upload_bytes > 0 && nar_size > max_upload_bytes)); then
      echo "Skipping oversized NAR: storePath=${store_path} name=${nar_name} size=${nar_size}B limit=${max_upload_bytes}B" >&2
      jq -cn \
        --arg key "$store_hash" \
        --arg store_path "$store_path" \
        --arg nar "$nar_name" \
        --arg reason "upload-size-limit" \
        --argjson size "$nar_size" \
        --argjson limit "$max_upload_bytes" \
        '{
          key: $key,
          value: {
            storePath: $store_path,
            nar: $nar,
            size: $size,
            limit: $limit,
            reason: $reason
          }
        }' >>"$skipped_updates_file"
      ((skipped_path_count += 1))
      continue
    fi

    object_urls["$nar_name"]="${download_base}/${generation_tag}/${nar_name}"

    if [[ -z ${queued_objects[$nar_name]:-} ]]; then
      printf '%s\t%s\n' "$nar_file" "$nar_name" >>"$nar_upload_queue"
      queued_objects["$nar_name"]=1
      ((new_nar_count += 1))
    fi

    jq -cn \
      --arg key "$nar_name" \
      --arg url "${object_urls[$nar_name]}" \
      --arg generation "$generation_tag" \
      --argjson size "${object_sizes[$nar_name]}" \
      '{key: $key, value: {url: $url, generation: $generation, size: $size}}' \
      >>"$object_updates_file"
  fi

  rewritten_file="${rewritten_dir}/${narinfo_name}"
  awk -v url="${object_urls[$nar_name]}" '
    BEGIN { replaced = 0 }
    /^URL: / {
      print "URL: " url
      replaced = 1
      next
    }
    { print }
    END { if (!replaced) exit 1 }
  ' "$narinfo_file" >"$rewritten_file"

  if [[ -n ${index_asset_ids[$narinfo_name]:-} ]]; then
    delete_asset "$index_release_id" "${index_asset_ids[$narinfo_name]}"
  fi
  printf '%s\t%s\n' "$rewritten_file" "$narinfo_name" >>"$narinfo_upload_queue"

  jq -cn \
    --arg key "$store_hash" \
    --arg url "${cache_uri}/${narinfo_name}" \
    --arg store_path "$store_path" \
    --arg nar "$nar_name" \
    '{key: $key, value: {url: $url, storePath: $store_path, nar: $nar}}' \
    >>"$narinfo_updates_file"
  ((new_narinfo_count += 1))
done < <(find "$cache_dir" -maxdepth 1 -type f -name '*.narinfo' -print0 | sort -z)

echo "Uploading ${new_nar_count} new NAR objects to '${generation_tag}'..."
upload_queue "$generation_release_id" "$nar_upload_queue"

echo "Uploading ${new_narinfo_count} new narinfo files to '${index_tag}'..."
upload_queue "$index_release_id" "$narinfo_upload_queue"

now=$(date -u +%Y-%m-%dT%H:%M:%SZ)
generations_file="${work_dir}/generations.json"
jq --arg prefix "$generation_prefix" '
  [
    .[]
    | select(.tag_name | startswith($prefix))
    | {
        tag: .tag_name,
        commit: .target_commitish,
        createdAt: .created_at
      }
  ]
' "$all_releases_file" >"$generations_file"

jq -s \
  --slurpfile object_updates "$object_updates_file" \
  --slurpfile narinfo_updates "$narinfo_updates_file" \
  --slurpfile skipped_updates "$skipped_updates_file" \
  --slurpfile generations "$generations_file" \
  --arg generation_tag "$generation_tag" \
  --arg commit "$commit" \
  --arg now "$now" \
  '
    .[0]
    | .skipped = (.skipped // {})
    | reduce $object_updates[] as $update (.; .objects[$update.key] = $update.value)
    | reduce $skipped_updates[] as $update (.; .skipped[$update.key] = $update.value)
    | reduce $narinfo_updates[] as $update (.;
        .narinfos[$update.key] = $update.value
        | del(.skipped[$update.key])
      )
    | .generatedAt = $now
    | .objects as $objects
    | .generations = (
        reduce (
          $generations[0] + [{tag: $generation_tag, commit: $commit, createdAt: $now}]
        )[] as $generation (
          {};
          .[$generation.tag] = $generation
        )
        | [.[]]
        | sort_by(.createdAt)
        | map(
            . as $generation
            | . + {
                objects: [
                  $objects
                  | to_entries[]
                  | select(.value.generation == $generation.tag)
                  | .key
                ]
              }
          )
      )
  ' "$manifest_file" >"${manifest_file}.new"
mv "${manifest_file}.new" "$manifest_file"

if [[ $mode == bootstrap ]]; then
  for root_asset_name in nix-cache-info cache-public-key; do
    root_asset_id=${index_asset_ids[$root_asset_name]:-}
    if [[ -n $root_asset_id ]]; then
      delete_asset "$index_release_id" "$root_asset_id"
    fi
  done
  upload_asset "$index_release_id" "${cache_dir}/nix-cache-info" nix-cache-info
  printf '%s\n' "$public_key" >"${work_dir}/cache-public-key"
  upload_asset "$index_release_id" "${work_dir}/cache-public-key" cache-public-key
fi

manifest_asset_name=cache-manifest.json
old_manifest_asset_id=${index_asset_ids[$manifest_asset_name]:-}
temporary_manifest_name="cache-manifest-${commit}.json"
while IFS= read -r stale_temporary_asset_id; do
  delete_asset "$index_release_id" "$stale_temporary_asset_id"
done < <(
  jq -r '
    .assets[]?
    | select(.name | test("^cache-manifest-[0-9a-f]+\\.json$"))
    | .id
  ' "$index_release_file"
)

temporary_manifest_asset=$(
  upload_asset_response "$index_release_id" "$manifest_file" "$temporary_manifest_name"
)
temporary_manifest_asset_id=$(jq -r '.id' <<<"$temporary_manifest_asset")
if [[ -z $temporary_manifest_asset_id || $temporary_manifest_asset_id == null ]]; then
  echo "Could not determine the temporary manifest asset ID." >&2
  exit 1
fi

if [[ -n $old_manifest_asset_id ]]; then
  delete_asset "$index_release_id" "$old_manifest_asset_id"
fi
rename_asset "$index_release_id" "$temporary_manifest_asset_id" "$manifest_asset_name"

echo "Published Nix cache generation: ${generation_tag}"
echo "Cache URI: ${cache_uri}"
echo "Public key: ${public_key}"
if ((skipped_path_count > 0)); then
  echo "Skipped ${skipped_path_count} store paths whose compressed NAR exceeded ${max_upload_bytes} bytes. They are listed in cache-manifest.json and will fall back to another substituter or a local build." >&2
fi

if ((${#failed_hosts[@]} > 0)); then
  echo "Cache publication succeeded, but the following host builds failed:" >&2
  printf '  - %s\n' "${failed_hosts[@]}" >&2
  exit 1
fi
