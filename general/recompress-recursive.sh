#!/bin/bash
rr_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./recompress.sh
. "${rr_called_path%/*}/recompress.sh" || return 1
recompress_recursive() {
	# Usage: a filename or directory, followed by a list of extensions; if
	# the filename matches any of the extensions, we call recompress on it.
#	shopt -s -q nullglob
	filename="${1}"
	shift
	if [ -f "${filename}" ]
	then
		for ext in "$@"; do
			# If the filename consists entirely of the extension,
			# skip it. FIXME: What if the entire filename consists
			# of it, but we're given its full path?
			if [ "${ext}" = "${filename}" ]; then
				continue
#			elif [ "$(basename "${filename}")" != \
#					"$(basename "${filename}" "${a}")" ]
			# If the filename has the extension ${ext}, we want to recompress it.
			elif [ "${filename}" != "${filename%${ext}}" ]
			then
				recompress "${filename}"
				return $?
			fi
		done
	elif [ ! -d "${filename}" ]; then
		echo "$0: ${filename} is neither a regular file nor a directory" 1>&2
		return 1
	else
		#echo Entering "${filename}" ...
		for xx in "${filename}"/*; do
			if ! recompress_recursive "${xx}" "$@"; then
				return 2
			fi
		done
		#echo Leaving "${filename}" ...
	fi
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	recompress_recursive "$@"
fi
