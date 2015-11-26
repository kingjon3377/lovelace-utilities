#!/bin/sh
called_path=$_
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
		*${ext}) mv -iv "${f}" "${f%%${ext}}${extlower}" ;;
		*) ;;
		esac
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	tolower_ext "$@"
fi

