#!/bin/sh
rr_called_path=$_
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
			recompress_recursive "${xx}" "$@"
			if [ $? -ne 0 ]; then
				return 2
			fi
		done
		#echo Leaving "${filename}" ...
	fi
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${rr_called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        recompress_recursive "$@"
fi
