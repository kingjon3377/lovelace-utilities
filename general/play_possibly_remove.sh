#!/bin/sh
called_path=$_
play_possibly_remove() {
	if [ "${VIDEO:-true}" = true ]; then
		PLAYER_COMMAND="${PLAYER_COMMAND:-mplayer -vo x11}"
	else
		PLAYER_COMMAND="${PLAYER_COMMAND:-mplayer -novideo}"
	fi
	for a in "$@"; do
		${PLAYER_COMMAND} "${a}" && rm -i "${a}"
	done
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        play_possibly_remove "$@"
fi
