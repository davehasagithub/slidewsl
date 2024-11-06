#!/bin/bash

script_dir="$(cd "$(dirname "$0")" && pwd)"
assets_dir="src/assets"
batch_script="src/slidewsl.bat"
distribution="dist/getslidewsl.bat"
temp_file=$(mktemp)

cleanup() {
  echo cleanup
  rm -f "$temp_file"
  echo "done"
}

encode_assets() {
  chunk_size=1024
  tar_command="tar czf - -C $script_dir/$assets_dir ."
  asset_encoded_tar=$(eval "$tar_command" | xxd -p | tr -d '\n')
  length=${#asset_encoded_tar}
  LF=$'\n'
  num_chunks=$(( (length + chunk_size - 1) / chunk_size ))
  printf '%s' "set num_chunks=$num_chunks${LF}" >"$temp_file"
  for (( i = 0, y = 1; i < length; i += chunk_size, y++ )); do
    chunk="${asset_encoded_tar:i:chunk_size}"
    chunk=$(printf '%s' "$chunk"|base64 -w 0)
    printf '%s' "set \"asset_encoded_tar_$y=$chunk\"${LF}" >>"$temp_file"
  done
}

trap cleanup EXIT

encode_assets

sed "/placeholder1/c\\@REM Built $(date)" <"$script_dir/$batch_script" | \
  sed "/placeholder2/{r $temp_file
  d}" >"$script_dir/$distribution"
