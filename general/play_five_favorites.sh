#!/bin/bash
cm_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
play_five_favorites() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		MUSIC_COLLECTION_BASE=${MUSIC_COLLECTION_BASE:-/home/kingjon/music}
		MUSIC_COLLECTION_FAVORITES=${MUSIC_COLLECTION_FAVORITES:-favorites}
		MUSIC_COLLECTION_XMAS=${MUSIC_COLLECTION_XMAS:-xmas}
		MUSIC_COLLECTION_EASTER=${MUSIC_COLLECTION_EASTER:-easter}
		# PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer -novideo}
		PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer}
	fi
	ORIG_PWD="${PWD}"
	cd "${MUSIC_COLLECTION_BASE}" || return
	usage() {
		echo 'Usage: play_five_favorites [[--][no[-]]remove] [[--][no]xmas] [[--][no[-]]video] [COUNT]' 
		echo '  Select five music files at random and play them.'
		echo '	noremove --noremove no-remove --no-remove: Do not remove any files.' 
		echo '	remove --remove: Ask after each file whether to remove it (default).' 
		echo '	xmas --xmas christmas --christmas: Play from Christmas collection (default in Christmastide).'
		echo '  easter --easter: Play from Easter collection.'
		echo '	noxmas --noxmas nochristmas --nochristmas: Play from favorites (default in other seasons).'
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
		FAVORITES=${MUSIC_COLLECTION_XMAS}
	elif [ ${EASTER:-false} = true ]; then
		FAVORITES=${MUSIC_COLLECTION_EASTER}
	else
		FAVORITES=${MUSIC_COLLECTION_FAVORITES}
	fi
	PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer}
	# We add a sort command to force one list ... I think that because of
	# buffering, some files were getting played twice
	file_list=$(find "${FAVORITES}" -type f | sort | shuf -n "${REPS:-5}")
	if [ ${REMOVE:-true} = true ]; then
		for a in ${file_list}; do
			${PLAYER_COMMAND} "${a}" && rm -i "${a}"
		done
	else
		# File list is file-separated, and player command may include options
		# TODO: Figure out some way to mitigate these
		# shellcheck disable=SC2086
		${PLAYER_COMMAND} ${file_list}
	fi
	# No need to return if the last command of a function fails
	# shellcheck disable=SC2164
	cd "${ORIG_PWD}"
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	play_five_favorites "$@"
fi
