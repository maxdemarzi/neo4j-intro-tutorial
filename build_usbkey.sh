#!/bin/bash

set -e

dist_dir=$(cd "`dirname "$0"`" && pwd)
volumes_dir=/Volumes
blank_volume_name="USB DISK"
target_volume_name="NEO4J"

blank_volume="$volumes_dir/$blank_volume_name"
target_volume="$volumes_dir/$target_volume_name"

set -x

diskutil renameVolume "$blank_volume" "$target_volume_name"
sleep 5
mdutil -i off "$target_volume"
sleep 3
rsync -avP --delete "$dist_dir/USBKEY/" "$target_volume/"
find "$target_volume" -name '.*' -delete
diskutil eject "$target_volume"
