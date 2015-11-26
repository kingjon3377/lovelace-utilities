#!/bin/sh
called_path=$_
play_five_favorites() {
	ORIG_PWD="${PWD}"
	cd ~/music || return
	local DATE
	local XMAS
	local FAVORITES
	local PLAYER_COMMAND
	local VIDEO
	local REPS
	usage() {
		echo 'Usage: play_five_favorites [[--][no[-]]remove] [[--][no]xmas] [[--][no[-]]video] [COUNT]' 
		echo '  Select five music files at random and play them.'
		echo '	noremove --noremove no-remove --no-remove: Do not remove any files.' 
		echo '	remove --remove: Ask after each file whether to remove it (default).' 
		echo '	xmas --xmas christmas --christmas: Play from Christmas collection (default in Christmastide).'
		echo '	noxmas --noxmas nochristmas --nochristmas: Play from favorites (default in other seasons).'
		echo '	video --video: If a file includes video, play it as well as the audio.'
		echo '	novideo --novideo no-video --no-video: Play audio only for all files (default).'
		echo '	COUNT: How many files to play (5 by default).'
	}
	while [ $# -gt 0 ];do
		case "${1}" in
			noremove | --noremove | no-remove | --no-remove) REMOVE=false ;;
			xmas | --xmas | christmas | --christmas) XMAS=true EASTER=false ;;
			noxmas | --noxmas | nochristmas | --nochristmas) XMAS=false ;;
			remove | --remove) REMOVE=true ;;
			easter | --easter) XMAS=false EASTER=true ;;
			--noeaster | noeaster) EASTER=false ;;
			video | --video) VIDEO=true ;;
			novideo | --novideo | no-video | --no-video) VIDEO=false ;;
			[0-9]*) REPS=${1} ;;
			*) usage ; return 1;;
		esac
		shift
	done
	DATE=$(date +%m%d|sed -e 's/^0//')
	if [ "${DATE}" -ge 1225 ] || [ "${DATE}" -le 105 ]; then
		XMAS=${XMAS:-true}
	else
		XMAS=${XMAS:-false}
	fi
	if [ ${XMAS} = true ]; then
		FAVORITES=xmas
	elif [ ${EASTER:-false} = true ]; then
		FAVORITES=easter
	else
		FAVORITES=favorites
	fi
	if [ ${VIDEO:-false} = true ]; then
		PLAYER_COMMAND="mplayer"
	else
		PLAYER_COMMAND="mplayer -novideo"
	fi
	# We add a sort command to force one list ... I think that because of
	# buffering, some files were getting played twice
	file_list=$(find ${FAVORITES} -type f | sort | shuf -n "${REPS:-5}")
	if [ ${REMOVE:-true} = true ]; then
		for a in ${file_list}; do
			${PLAYER_COMMAND} "${a}" && rm -i "${a}"
		done
	else
		${PLAYER_COMMAND} ${file_list}
	fi
	cd "${ORIG_PWD}"
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        play_five_favorites "$@"
fi
