#!/bin/sh
called_path=$_
get_music_duration() {
	midentify "${1}" | grep -e '^ID_LENGTH' | tac | sed -e 's@^ID_\(FILENAME\|LENGTH\)=@@' -e 's@^\([0-9]*\)\.[0-9]*$@\1@' | tr '\n' ' '
	echo "${1}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	for file in "$@";do
		get_music_duration "$file"
	done
fi
