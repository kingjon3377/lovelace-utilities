#!/bin/bash
# Test whether a file is in any of the "favorites" directories; if the file
# fails to exist in any of them (or doesn't exist at the filename passed in),
# the exit code is 1, while if it exists in all of them the exit code is 0.

# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
lovelace_utilities_source_config_bash
MUSIC_COLLECTION=${MUSIC_COLLECTION:-/home/kingjon/music}
test "${#MUSIC_FAVORITES_DIRS[@]}" -lt 1 && MUSIC_FAVORITES_DIRS=( favorites xmas easter )
for file in "${1}"/*;do
	if test -d "${file}"; then
		exit 1
	fi
	for dir in "${MUSIC_FAVORITES_DIRS[@]}"; do
		test -f "${MUSIC_COLLECTION}/${dir}/${file}" || exit 1
	done
done
exit 0
