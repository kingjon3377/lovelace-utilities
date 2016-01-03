#!/bin/bash
# This is designed to be sourced in bash.
if [ "${BASH_SOURCE}" = "$0" ]; then
        echo "Source this file, don\'t execute it."
	exit 1
fi
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
lovelace_utilities_source_config_bash
if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
    MUSIC_COLLECTION=${MUSIC_COLLECTION:-/home/kingjon/music}
    MUSIC_ROOT_DIRS=( choirs itunes sorted )
fi
setup() {
	find "${MUSIC_ROOT_DIRS[@]/#/${MUSIC_COLLECTION}/}" -type d | while read -r a; do
		pushd "${a}" > /dev/null
	done
	until [ -e .bookmark ]; do
		popd > /dev/null
	done
	dirs
	ls
}

advance() {
	rm .bookmark;popd;touch .bookmark;ls
}

edit_tags() {
	for file in *ogg; do
		vorbiscomment -c "${file%%.ogg}".tag "${file}"
	done
	vim ./*tag
}

apply_tags() {
	for file in *.ogg;do
		vorbiscomment -c "${file%%.ogg}".tag "${file}" -w && \
			rm "${file%%.ogg}.tag"
	done
}
