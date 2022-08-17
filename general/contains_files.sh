#!/bin/sh
# Test whether the directory passed as $1 contains any (regular, i.e. non-directory) files.
# TODO: Convert to a function.
# My usual usage of this script is in something like the following:
# for dir in $(find music -type d -exec /path/to/contains_files.sh {} \; -print);do pushd "${dir}";done

cd "${1}" || exit 1
for file in *;do
	test -f "${file}" && exit 0
done
exit 1
