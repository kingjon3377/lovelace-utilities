#!/bin/sh
cm_called_path=$_
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
play_possibly_remove() {
    lovelace_utilities_source_config
    local PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer -novideo}
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
