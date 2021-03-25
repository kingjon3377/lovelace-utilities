#!/bin/bash
# The sourced file uses bashisms, and I think so do we here.
# shellcheck source=./keep_image.sh
. "${BASH_SOURCE[0]%/*}/keep_image.sh"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
get_favorite_images() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		SOURCE_DIRECTORY=${SOURCE_DIRECTORY:-${HOME}/media/photos}
		NEW_DIR=${NEW_DIR:-${HOME}/media/favorite_photos}
		RECORD=${RECORD:-${NEW_DIR}/checked.txt}
		FAV_FILE=${FAV_FILE:-${NEW_DIR}/favorite_photos.txt}
	fi
	if ! pushd "${SOURCE_DIRECTORY}" > /dev/null; then
		echo "Can't enter SOURCE_DIRECTORY" 1>&2
		return 3
	fi
	mkdir -p "${NEW_DIR}"
	PIPE=$(mktemp -u)
	mkfifo -m600 "${PIPE}"
	find ./*/ -type f >"${PIPE}" &
	exec 3<"${PIPE}"
	touch "${RECORD}"
	while read -r -u 3 file; do
		grep -q -x -F "$(realpath "${SOURCE_DIRECTORY}/${file}")" "${RECORD}" && continue
		case "${file}" in
		*wks|*txt|*ods) continue ;;
		esac
		keep_image "${file}"
		test -f "${file}" || continue
		if ! pushd "${NEW_DIR}" > /dev/null; then
			echo "Can't enter NEW_DIR" 1>&2
			return 4
		fi
		# TODO: Make the following process, in both branches, more generic, to work with other dialog implmentations etc.
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
				resp=$(grabchars -q"Is ${file} a favorite? " -b -cynq -dn)
				if test "${resp}" = y;then
					mkdir -p "$(dirname "${file}")"
					cp -l "${SOURCE_DIRECTORY}/${file}" "${file}"
					echo "${NEW_DIR}/${file}" >> "${FAV_FILE}"
				elif test "${resp}" = q;then
					break
				elif test "${resp}" = n;then
					:
				else
					echo "grabchars isn't working!" 1>&2
					break
				fi
			fi
		fi
		if ! popd > /dev/null; then
			echo "Failed to return to SOURCE_DIRECTORY" 1>&2
			return 5
		fi
		realpath "${SOURCE_DIRECTORY}/${file}" >> "${RECORD}"
		if test "$(grabchars -q"Keep going? " -b -cyn -dy -t3)" != y;then
			break
		fi
	done
	rm "${PIPE}"
	popd > /dev/null || return $?
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	get_favorite_images "$@"
fi
