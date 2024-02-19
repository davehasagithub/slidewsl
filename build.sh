#!/bin/bash

script_dir="$(cd "$(dirname "$0")" && pwd)"
batch_script="$script_dir/src/slidewsl.bat"
shell_script="$script_dir/src/slidewsl.sh"
distribution="$script_dir/dist/getslidewsl.bat"

cleanup() {
  rm -f "$temp_file"
}

temp_file=$(mktemp)
trap cleanup EXIT

chunk_size=1024
shell_script_content=$(cat "$shell_script")
length=${#shell_script_content}
LF=$'\n'
num_chunks=$(( (length + chunk_size - 1) / chunk_size ))
printf '%s' "set num_chunks=$num_chunks${LF}" >"$temp_file"
for (( i = 0, y = 1; i < length; i += chunk_size, y++ )); do
  chunk="${shell_script_content:i:chunk_size}"
  chunk=$(printf '%s' "$chunk"|base64 -w 0)
  printf '%s' "set \"shell_script_content_$y=$chunk\"${LF}" >>"$temp_file"
done

(
  echo @REM
  echo @REM slidewsl
  echo @REM
  echo @REM The Simple Linux Interface for DEveloping on WSL
  echo @REM
  echo @REM built "$(date)"
  echo @REM
  echo @REM warning: this script will run wsl --shutdown
  echo @REM
  echo @REM ---------------------------------------------------------------
  echo
) >"$distribution"

sed "/placeholder1/{r $temp_file
d}" <$batch_script >>"$distribution"
