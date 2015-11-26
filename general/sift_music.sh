#!/bin/sh
called_path=$_
sift_music() {
	local PLAYER_COMMAND
	local VIDEO
	while [ $# -gt 0 ];do
		case "${1}" in
			video | --video) VIDEO=true ;;
			novideo | --novideo | no-video | --no-video) VIDEO=false ;;
			*) [ -d "${1}" ] && FAVORITES="${1}" ;;
		esac
		shift
	done
	if [ ${VIDEO:-false} = true ]; then
		PLAYER_COMMAND="mplayer"
	else
		PLAYER_COMMAND="mplayer -novideo"
	fi
	find "${FAVORITES:-~/music/favorites}" -type f| shuf | while read a; do
		${PLAYER_COMMAND} "${a}" && rm -i "${a}"
	done
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        sift_music "$@"
fi
