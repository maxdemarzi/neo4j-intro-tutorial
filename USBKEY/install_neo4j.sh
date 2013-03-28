#!/bin/bash

set -e

if ! java -version > /dev/null 2>&1; then
    echo "Cannot find java: install the Java Runtime Environment!" >&2
    exit 1;
fi

prefix="$HOME"
neo4j_version=1.9.M05

dist_dir=$(cd "`dirname "$0"`" && pwd)
release=neo4j-community-${neo4j_version}
installer=${release}-unix.tar.gz
package="${dist_dir}/NEO4J/$installer"

force=
while getopts ":f" opt; do
    case $opt in
    f) force=1;;
    *)
        echo "Invalid option -$OPTARG" >&2
        echo "Usage: $0 [-f] [prefix]" >&2
        exit 1;;
    esac
done
shift $((OPTIND-1))

if [ $# -gt 0 ]; then
    prefix=$1
fi

if ! [ -d "$prefix" ]; then
    echo "Directory $prefix does not exist!" >&2
    exit 1
fi

if [ -e "$prefix/$release" ]; then
    echo "Directory $prefix/$release already exists!" >&2
    exit 1
fi

if [ "X$force" = "X" ]; then
    echo -n "Install Neo4j ${neo4j_version} to ${prefix}? [y/N] "
    read response
    case $response in
    Y|y) ;;
    *) exit 1;;
    esac
fi

echo "Unpacking $package"
(cd "$prefix" && tar xzf "$package")

echo "Modifying default configuration"
cp "$dist_dir/CONFIG/neo4j.properties" "$prefix/$release/conf"

echo "Copying sample datasets"
mkdir "$prefix/$release/sample"
cp "$dist_dir"/SAMPLE/*.cyp "$prefix/$release/sample"

echo "Copying tools"
cp "$dist_dir"/TOOLS/gumdrop.jar "$prefix/$release"

echo
echo "Neo4j ${neo4j_version} installed to $prefix/$release"
exit 0
