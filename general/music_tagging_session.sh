#!/bin/bash
# This is designed to be sourced in bash.
if [ "${BASH_SOURCE}" = "$0" ]; then
        echo "Source this file, don\'t execute it."
	exit 1
fi
if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
        [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
    source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
        [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config-bash" ]; then
    source "${XDG_CONFIG_HOME}/lovelace-utilities/config-bash"
else
    MUSIC_COLLECTION=/home/kingjon/music
    MUSIC_ROOT_DIRS=( choirs itunes sorted )
fi
setup() {
	find "${MUSIC_ROOT_DIRS[@]/#/${MUSIC_COLLECTION}/}" -type d | while read a; do
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
