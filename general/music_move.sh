#!/bin/bash
# We use bashisms (string substitutions), so we also use the less portable but more reliable way of detecting sourceing.
move_if_exists() {
	if [ -e "${1}" ]; then
		test -d "${2%/*}" || mkdir -p "${2%/*}"
		mv -i "${1}" "${2}"
	fi
#	[ -e "${1}" ] && \
#		echo "Would move \"${1}\" to \"${2}\""
}
music_move() {
	MUSIC_ROOT=${MUSIC_ROOT:-~/music}
	if [ $# -ne 2 ]; then
		echo "Usage: music_move SRC DEST"
		echo "SRC and DEST both relative to music/ and the various collection-dirs."
		return 1
	fi
	case "${1}" in 
		music/*) music_move "${1/music\//}" "${2}" ; return $?;;
		sorted/*) MAIN_SRC_BASE=sorted/ ; XMAS_SRC_BASE=./ ; SRC="${1/sorted\//}" ;;
		itunes/*) MAIN_SRC_BASE=itunes/ ; XMAS_SRC_BASE=itunes/ ; SRC="${1/itunes\//}" ;;
		choirs/*) MAIN_SRC_BASE=choirs/ ; XMAS_SRC_BASE=choirs/ ; SRC="${1/choirs\//}" ;;
		*) echo "Source ${1} is outside what I know how to handle."; return 5 ;;
	esac
	case "${2}" in 
		music/*) music_move "${1}" "${2/music\//}" ; return $?;;
		sorted/*) MAIN_DEST_BASE=sorted/ ; XMAS_DEST_BASE=./ ; DEST="${2/sorted\//}" ;;
		itunes/*) MAIN_DEST_BASE=itunes/ ; XMAS_DEST_BASE=itunes/ ; DEST="${2/itunes\//}" ;;
		choirs/*) MAIN_DEST_BASE=choirs/ ; XMAS_DEST_BASE=choirs/ ; DEST="${2/choirs\//}" ;;
		*) echo "Dest ${1} is outside what I know how to handle."; return 6 ;;
	esac
	if [ ! -e "${MUSIC_ROOT}/${MAIN_SRC_BASE}/${SRC}" ]; then
		echo "Error: File ${MAIN_SRC_BASE}/${SRC} doesn't exist in the main collection, ${MUSIC_ROOT}."
		return 2
	elif [ -f "${MUSIC_ROOT}/${MAIN_DEST_BASE}/${DEST}" ]; then
		echo "Error: Destination already exists in main collection; this would throw off the rest of the script. Exiting."
		return 3
	elif [ -d "${MUSIC_ROOT}/${MAIN_DEST_BASE}/${DEST}" ]; then
		if test -d "${MUSIC_ROOT}/${MAIN_SRC_BASE}/${SRC}"; then
			# Source and dest are both directories; proceed as normal.w
			:
		else
			# Reassign DEST to be its original value plus the filename part of SRC.
			# TODO: Handle many-sources-one-directory-destination case like mv.
			DEST=${DEST}/"${SRC##*/}"
		fi
	fi
	mv -i "${MUSIC_ROOT}/${MAIN_SRC_BASE}/${SRC}" "${MUSIC_ROOT}/${MAIN_DEST_BASE}/${DEST}" || \
		return $?
	if [ -e "${MUSIC_ROOT}/favorites/${MAIN_SRC_BASE}/${SRC}" ]; then
#		echo "Moving in favorites"
		move_if_exists "${MUSIC_ROOT}/favorites/${MAIN_SRC_BASE}/${SRC}" \
				"${MUSIC_ROOT}/favorites/${MAIN_DEST_BASE}/${DEST}" || \
			return $?
	fi
	if [ -e "${MUSIC_ROOT}/easter/${MAIN_SRC_BASE}/${SRC}" ]; then
#		echo "Moving in easter"
		move_if_exists "${MUSIC_ROOT}/easter/${MAIN_SRC_BASE}/${SRC}" \
				"${MUSIC_ROOT}/easter/${MAIN_DEST_BASE}/${DEST}" || \
			return $?
	fi
	if [ -e "${MUSIC_ROOT}/xmas/${XMAS_SRC_BASE}/${SRC}" ]; then
#		echo "Moving in xmas"
		move_if_exists "${MUSIC_ROOT}/xmas/${XMAS_SRC_BASE}/${SRC}" \
				"${MUSIC_ROOT}/xmas/${XMAS_DEST_BASE}/${DEST}" || \
			return $?
	fi
	if [ -e "${MUSIC_ROOT}/favorites2/${MAIN_SRC_BASE}/${SRC}" ];then
#		echo "moving in favorites2"
		move_if_exists "${MUSIC_ROOT}/favorites2/${MAIN_SRC_BASE}/${SRC}" \
				"${MUSIC_ROOT}/favorites2/${MAIN_DEST_BASE}/${DEST}" || \
			return $?
	fi
}
if [ "${BASH_SOURCE}" = "$0" ]; then
	music_move "$@"
fi
