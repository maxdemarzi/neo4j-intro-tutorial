#!/bin/bash

set -e

dist_dir=$(cd "`dirname "$0"`" && pwd)
volumes_dir=/Volumes
volume_name="NEO4J"
blank_volume_name=

rsync_args="-avP --size-only --exclude '.*'"
clean=

usage() {
  echo "$0: [-f][-v name][-r name]"
  echo "  -c       Clean destination (remove MacOS related files)"
  echo "  -f       Force destination to match source (will delete extra files)"
  echo "  -v name  Name of volume to write to (default 'NEO4J')"
  echo "  -r name  Volume with this name will be renamed first"
}

while getopts ":cfhr:v:" opt; do
  case $opt in
  c) clean=1;;
  f) rsync_args="$rsync_args --delete --delete-excluded"; clean=1;;
  h) usage; exit 0;;
  v) volume_name=$OPTARG;;
  r) blank_volume_name=$OPTARG;;
  :) echo "Missing argument for: -$OPTARG" >&2; usage >&2; exit 1;;
  \?) echo "Invalid option: -$OPTARG" >&2; usage >&2; exit 1;;
  esac
done

if [ -z "$volume_name" ]; then
  echo "Invalid volume_name" >&2
  exit 1
fi

target_volume="$volumes_dir/$volume_name"

if [ -n "$blank_volume_name" ]; then
  if [ -d "$target_volume" ]; then
    echo "Volume '$volume_name' already exists!" >&2
    exit 1
  fi
  blank_volume="$volumes_dir/$blank_volume_name"
  if ! [ -d "$blank_volume" ]; then
    echo "Volume '$blank_volume_name' not found!" >&2
    exit 1
  fi
  set -x
  diskutil renameVolume "$blank_volume" "$volume_name"
  sleep 5
  set +x
fi

if ! [ -d "$target_volume" ]; then
  echo "Can't find '$target_volume'" >&2
  exit 1
fi

set -x
mdutil -i off "$target_volume"
sleep 3
rsync ${rsync_args} "$dist_dir/USBKEY/" "$target_volume/"
set +x

if [ -n "$clean" ]; then
  set -x
  find "$target_volume" -name '.DS_Store' -delete
  rm -rf "$target_volume/.Trashes"
  rm -rf "$target_volume/.fseventsd"
  rm -rf "$target_volume/._.Trashes"
  rm -rf "$target_volume/.Spotlight-V100"
  set +x
fi

set -x
diskutil eject "$target_volume"
