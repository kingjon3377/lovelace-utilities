#!/bin/bash
# We use bashisms, namely bash arrays, so we use the more reliable but
# nonportable method of detecting sourceing.
# TODO: Should we source the config file unconditionally? If so, should we define MUSIC_COLLECTION etc. globally?
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        source "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash" ]; then
        source "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash"
    else
        MUSIC_COLLECTION=/home/kingjon/music
        MUSIC_ROOT_DIRS=( choirs itunes sorted )
        MUSIC_FAVORITES_DIR=${MUSIC_COLLECTION}/favorites
        MUSIC_COLLECTION_RECORD=${MUSIC_COLLECTION}/checked.txt
        PLAYER_COMMAND=mplayer
    fi
fi
# TODO: Make a way to handle multiple 'favorites' directories (e.g. favorites, easter, xmas) at once
create_new_favorites() {
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
if [ "${BASH_SOURCE}" = "$0" ]; then
        create_new_favorites "$@"
fi
