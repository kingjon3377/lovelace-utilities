#!/bin/sh
cd ~ || exit 1
find . /debian \( -path ./.mozilla -o -path ./.avfs -o -path ./temp \) -prune -o \( -iname "*.${1}" -o -iname "*.${1}.gz" -o -iname "*.${1}.bz2" -o -iname "*.${1}.rz" -o -iname "*.${1}.lrz" -o -iname "*.${1}.xz" \) -print
