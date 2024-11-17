#!/bin/bash
# Bash specified because we need a nonstandard echo flag.
# TODO: Extract the zenity handling to a separate script/function?
keep_image() {
	for file in "$@";do
		if test -n "${DISPLAY}"; then
			width=$(identify -format "%w" "${file}")
			height=$(identify -format "%h" "${file}")
			width=$((width + 40))
			height=$((height + 60))
			test "${width}" -gt 800&&width=800
			test "${height}" -gt 600&&height=600
			{
				echo "<h2>Keep ${file}?</h2><img src=\"data:"
				mimetype -b "${file}"
				echo -n ";base64,"
				base64 "${file}"
				echo "\">"
			} | zenity --text-info --html --filename=/dev/stdin \
				--ok-label="Keep" --cancel-label="Remove" \
				--width="${width}" --height="${height}" --title="Keep Image?"
			test $? -eq 1 && rm -i "${file}"
		else
			if ! test -f "${file}"; then
				echo "$(pwd)/${file} not found" 1>&2
				exit 5
			fi
			keep=$(fbi --autodown "${file}")
			if test "${keep}" = "${file}"; then
				continue;
			else
				resp=$(grabchars -q"Keep ${file}? "  -b -cynq -dy)
				if test "${resp}" = q; then
					break;
				elif test "${resp}" = n; then
					rm -i "${file}"
				fi
			fi
		fi
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	keep_image "$@"
fi
