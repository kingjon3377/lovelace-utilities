#!/bin/bash
# This script has to be a Bash script because it uses process substitution, so
# we use the more reliable method of sourceing-detection.
# We also use the BASH_SOURCE variable to find the location of the fbi_filter script.
. "${BASH_SOURCE[0]%/*}/fbi_filter.sh"
# TODO: Should we source the config file unconditionally? If so, should we define VIEWER globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config" ]; then
        source "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config"
    else
        VIEWER=${VIEWER:-fbi}
    fi
fi
check_image() {
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
