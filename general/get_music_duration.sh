#!/bin/bash
get_music_duration() {
	midentify "${1}" | grep -e '^ID_LENGTH' | tac | sed -e 's@^ID_\(FILENAME\|LENGTH\)=@@' -e 's@^\([0-9]*\)\.[0-9]*$@\1@' | tr '\n' ' '
	echo "${1}"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	for file in "$@";do
		get_music_duration "${file}"
	done
fi
