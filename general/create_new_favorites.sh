#!/bin/bash
# We use bashisms, namely bash arrays, so we use the more reliable but
# nonportable method of detecting this script's directory
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
# TODO: Make a way to handle multiple 'favorites' directories (e.g. favorites, easter, xmas) at once
create_new_favorites() {
    lovelace_utilities_source_config_bash
    if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
        MUSIC_COLLECTION=${MUSIC_COLLECTION:-/home/kingjon/music}
        MUSIC_ROOT_DIRS=( choirs itunes sorted )
        MUSIC_FAVORITES_DIR=${MUSIC_FAVORITES_DIR:-${MUSIC_COLLECTION}/favorites}
        MUSIC_COLLECTION_RECORD=${MUSIC_COLLECTION_RECORD:-${MUSIC_COLLECTION}/checked.txt}
        PLAYER_COMMAND=${PLAYER_COMMAND:-mplayer}
    fi
	pushd "${MUSIC_COLLECTION}" > /dev/null
	mkdir -p "${MUSIC_FAVORITES_DIR}"
	PIPE=$(mktemp -u)
	mkfifo -m600 "${PIPE}"
	find "${MUSIC_ROOT_DIRS[@]}" -type f >"${PIPE}" &
	exec 3<"${PIPE}"
	while read -r -u 3 file; do
		grep -q -x -F "${MUSIC_COLLECTION}/${file}" "${MUSIC_COLLECTION_RECORD}" && continue
		pushd "${MUSIC_FAVORITES_DIR}" > /dev/null
		"${PLAYER_COMMAND}" "${MUSIC_COLLECTION}/${file}" || return
		response=$(grabchars -cyn -n1 -b -L -f -t10 -dn -q"Is ${file} a favorite? ")
		echo
		if test "${response}" = 'y'; then
			mkdir -p "$(dirname "${file}")"
			cp -l "${MUSIC_COLLECTION}/${file}" "${file}"
		fi
		popd > /dev/null
		echo "${MUSIC_COLLECTION}/${file}" >> "${MUSIC_COLLECTION_RECORD}"
	done
	rm "${PIPE}"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
        create_new_favorites "$@"
fi
