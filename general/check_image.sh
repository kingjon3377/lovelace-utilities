#!/bin/bash
# This script has to be a Bash script because it uses process substitution, so
# we use the more reliable method of sourceing-detection.
. ~/bin/fbi_filter.sh
check_image() {
	VIEWER=${VIEWER:-fbi}
	FAVORITES_FILE=${2:-favorites.txt}
	ALL_FILE=${3:-all_images.txt}
	if grep -q "${1}" "${FAVORITES_FILE}"; then
		return
	elif grep -q "${1}" "${ALL_FILE}"; then
		return
	else
		fbi -a "${1}" >> "${FAVORITES_FILE}" 2> >(fbi_filter)
		grep -q "${1}" "${FAVORITES_FILE}" || echo "${1}" >> "${ALL_FILE}"
	fi
}
[ "${BASH_SOURCE}" = "$0" ] && check_image "$@"
