#!/bin/bash
tolower_ext() {
	if [ $# -lt 2 ]; then
		echo "Usage: tolower_ext EXT file [file ...]" 
		return 1
	fi
	ext=$1
	extlower=$(echo "${ext}" | tr '[:upper:]' '[:lower:]')
	shift
	for f in "$@";do
		case ${f} in
		*${ext}) mv -iv "${f}" "${f%%"${ext}"}${extlower}" ;;
		*) ;;
		esac
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	tolower_ext "$@"
fi
