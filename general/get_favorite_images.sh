#!/bin/bash
# The sourced file uses bashisms, and I think so do we here.
. /home/kingjon/bin/keep_image.sh
get_favorite_images() {
	SOURCE_DIRECTORY=${SOURCE_DIRECTORY:-/home/kingjon/media/photos}
	NEW_DIR=${NEW_DIR:-/home/kingjon/media/favorite_photos}
	RECORD=${RECORD:-${NEW_DIR}/checked.txt}
	FAV_FILE=${FAV_FILE:-${NEW_DIR}/favorite_photos.txt}
	pushd "${SOURCE_DIRECTORY}" > /dev/null
	mkdir -p "${NEW_DIR}"
	PIPE=$(mktemp -u)
	mkfifo -m600 "${PIPE}"
	find ./*/ -type f >"${PIPE}" &
	exec 3<"${PIPE}"
	touch "${RECORD}"
	while read -r -u 3 file; do
		grep -q -x -F "${SOURCE_DIRECTORY}/${file}" "${RECORD}" && continue
		keep_image "${file}"
		test -f "${file}" || continue
		pushd "${NEW_DIR}" > /dev/null
		if test -n "${DISPLAY}"; then
			width=$(identify -format "%w" "${file}"); width=$((width + 40))
			height=$(identify -format "%h" "${file}"); height=$((height + 60))
			test ${width} -gt 800&&width=800
			test ${height} -gt 600&&height=600
			{
				echo "<h2>Is ${file} a favorite?</h2><img src=\"data:"
				mimetype -b "${file}"&&echo -n ';base64,'&&base64 "${file}"&&echo '">'
			} | zenity --text-info --html --filename=/dev/stdin \
				--width=${width} --height=${height} \
				--title="Favorite?" --ok-label="Favorite" --cancel-label="Not Favorite"
			if test $? -eq 0; then
				mkdir -p "$(dirname "${file}")"
				cp -l "${SOURCE_DIRECTORY}/${file}" "${file}"
				echo "${NEW_DIR}/${file}" >> "${FAV_FILE}"
			fi
		else
			favorite=$(fbi "${SOURCE_DIRECTORY}/${file}")
			if test "${favorite}" = "${file}"; then
				mkdir -p "$(dirname "${file}")"
				cp -l "${SOURCE_DIRECTORY}/${file}" "${file}"
				echo "${NEW_DIR}/${file}" >> "${FAV_FILE}"
			else
				resp=$(grabchars -q"Is ${file} a favorite? " -b -cyn -dn)
				if test "${resp}" = y;then
					mkdir -p "$(dirname "${file}")"
					cp -l "${SOURCE_DIRECTORY}/${file}" "${file}"
					echo "${NEW_DIR}/${file}" >> "${FAV_FILE}"
				fi
			fi
		fi
		popd > /dev/null
		echo "${SOURCE_DIRECTORY}/${file}" >> "${RECORD}"
		if test "$(grabchars -q"Keep going? " -b -cyn -dy -t3)" = n;then
			break
		fi
	done
	rm "${PIPE}"
	popd > /dev/null
}
if [ "${BASH_SOURCE}" = "$0" ]; then
        get_favorite_images "$@"
fi
