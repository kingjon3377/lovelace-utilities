#!/bin/bash
# We use bashisms, namely bash arrays, so we use the more reliable but
# nonportable method of detecting sourceing.
create_new_favorites() {
	MUSIC="${MUSIC:-/home/kingjon/music}"
	pushd "${MUSIC}" > /dev/null
	ROOT_DIRS=( choirs itunes sorted )
	NEW_DIR=${NEW_DIR:-${MUSIC}/favorites}
	RECORD=${RECORD:-${MUSIC}/checked.txt}
	mkdir -p "${NEW_DIR}"
	PIPE=$(mktemp -u)
	mkfifo -m600 "${PIPE}"
	find "${ROOT_DIRS[@]}" -type f >"${PIPE}" &
	exec 3<"${PIPE}"
	while read -r -u 3 file; do
		grep -q -x -F "${MUSIC}/${file}" "${RECORD}" && continue
		pushd "${NEW_DIR}" > /dev/null
		"${PLAYER_COMMAND:-mplayer}" "${MUSIC}/${file}" || return
		response=$(grabchars -cyn -n1 -b -L -f -t10 -dn -q"Is ${file} a favorite? ")
		echo
		if test "${response}" = 'y'; then
			mkdir -p "$(dirname "${file}")"
			cp -l "${MUSIC}/${file}" "${file}"
		fi
		popd > /dev/null
		echo "${MUSIC}/${file}" >> "${RECORD}"
	done
	rm "${PIPE}"
}
if [ "${BASH_SOURCE}" = "$0" ]; then
        create_new_favorites "$@"
fi
