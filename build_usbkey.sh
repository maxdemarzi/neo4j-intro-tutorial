#!/bin/bash

set -e

dist_dir=$(cd "`dirname "$0"`" && pwd)
volumes_dir=/Volumes
blank_volume_name="USB DISK"
target_volume_name="NEO4J"

blank_volume="$volumes_dir/$blank_volume_name"
target_volume="$volumes_dir/$target_volume_name"

if [ -d "$blank_volume" ]; then
  set -x
  diskutil renameVolume "$blank_volume" "$target_volume_name"
  sleep 5
  set +x
fi
if ! [ -d "$target_volume" ]; then
  echo "Can't find \"$target_volume\"" >&2
  exit 1
fi
set -x
mdutil -i off "$target_volume"
sleep 3
rsync -avP --size-only --exclude '.*' "$dist_dir/USBKEY/" "$target_volume/"
find "$target_volume" -name '.*' -delete
diskutil eject "$target_volume"
