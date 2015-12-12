#!/bin/sh
cd ~ || exit 1
if ! declare -p FIND_EXT_BASE > /dev/null; then
    FIND_EXT_BASE=( /debian )
fi
find . "${FIND_EXT_BASE[@]}" \( -path ./.mozilla -o -path ./.avfs -o -path ./temp \) -prune -o \( -iname "*.${1}" -o -iname "*.${1}.gz" -o -iname "*.${1}.bz2" -o -iname "*.${1}.rz" -o -iname "*.${1}.lrz" -o -iname "*.${1}.xz" \) -print
