#!/bin/sh
called_path=$_
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME}/lovelace-utilities/config"
    else
        MUSIC_COLLECTION_BASE=/home/kingjon/music
        MUSIC_COLLECTION_FAVORITES=favorites
        MUSIC_COLLECTION_XMAS=xmas
        MUSIC_COLLECTION_EASTER=easter
        # PLAYER_COMMAND=mplayer -novideo
        PLAYER_COMMAND=mplayer
    fi
fi
play_all_favorites() {
	ORIG_PWD="${PWD}"
	cd "${MUSIC_COLLECTION_BASE}" || return
	local DATE
	local XMAS
	local PLAYER_COMMAND
	local FAVORITES
	while [ $# -gt 0 ];do
		case "${1}" in
			noremove | --noremove | no-remove | --no-remove) REMOVE=false ;;
			xmas | --xmas | christmas | --christmas) XMAS=true EASTER=false ;;
			noxmas | --noxmas | nochristmas | --nochristmas) XMAS=false ;;
			remove | --remove) REMOVE=true ;;
			easter | --easter) XMAS=false EASTER=true ;;
			--noeaster | noeaster) EASTER=false ;;
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
	file_list=$(find ${FAVORITES} -type f | sort | shuf)
	if [ ${REMOVE:-true} = true ]; then
		count=$(echo "${file_list}" | wc -l)
		curr=0
		for a in ${file_list}; do
			echo "File ${curr} / ${count}"
			${PLAYER_COMMAND} "${a}" && rm -i "${a}"
			curr=$((curr + 1))
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
        play_all_favorites "$@"
fi
