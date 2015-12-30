#!/bin/bash
# We use bashisms (string substitutions), so we also use the less portable but more reliable way of detecting sourceing.
# TODO: Should we source the config file unconditionally? If so, should we define MUSIC_COLLECTION etc. globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash" ]; then
        source "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash"
    else
        MUSIC_COLLECTION=${HOME}/music
        MUSIC_ROOT_DIRS=( choirs itunes sorted )
        MUSIC_FAVORITES_DIRS=( favorites xmas easter )
    fi
fi
move_if_exists() {
	if [ -e "${1}" ]; then
		test -d "${2%/*}" || mkdir -p "${2%/*}"
		mv -i "${1}" "${2}"
	fi
#	[ -e "${1}" ] && \
#		echo "Would move \"${1}\" to \"${2}\""
}
music_move() {
	if [ $# -ne 2 ]; then
		echo "Usage: music_move SRC DEST"
		echo "SRC and DEST both relative to music/ and the various collection-dirs."
		return 1
	fi
    BASE=$(realpath --relative-to="${HOME}" "${MUSIC_COLLECTION}")
    SRC="${1##${BASE}}"
    SRC="${SRC##/}"
    DEST="${1##${BASE}}"
    DEST="${DEST##/}"
    for dir in "${MUSIC_FAVORITES_DIRS[@]}";do
        SRC="${SRC##${dir}}"
        SRC="${SRC##/}"
        DEST="${DEST##${dir}}"
        DEST="${DEST##/}"
    done
	if [ ! -e "${MUSIC_COLLECTION}/${SRC}" ]; then
		echo "Error: File ${SRC} doesn't exist in the main collection, ${MUSIC_COLLECTION}."
		return 2
	elif [ -f "${MUSIC_COLLECTION}/${DEST}" ]; then
		echo "Error: Destination already exists in main collection; this would throw off the rest of the script. Exiting."
		return 3
	elif [ -d "${MUSIC_COLLECTION}/${DEST}" ]; then
		if test -d "${MUSIC_COLLECTION}${SRC}"; then
			# Source and dest are both directories; proceed as normal.
			:
		else
			# Reassign DEST to be its original value plus the filename part of SRC.
			# TODO: Handle many-sources-one-directory-destination case like mv.
			DEST="${DEST}/${SRC##*/}"
		fi
	fi
	mv -i "${MUSIC_COLLECTION}/${SRC}" "${MUSIC_COLLECTION}/${DEST}" || \
		return $?
    for dir in "${MUSIC_FAVORITES_DIRS[@]}"; do
        if test -e "${MUSIC_COLLECTION}/${dir}/${SRC}"; then
            move_if_exists "${MUSIC_COLLECTION}/${dir}/${SRC}" \
                    "${MUSIC_COLLECTION}/${dir}/${DEST}" || \
                return $?
        fi
    done
}
if [ "${BASH_SOURCE}" = "$0" ]; then
	music_move "$@"
fi
