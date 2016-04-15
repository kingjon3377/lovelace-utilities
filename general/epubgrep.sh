#!/bin/sh
called_path=$_
epubgrep() {
	pattern=$1;shift
	for file in "$@";do
		case "${file}" in
		*.epub|*.zip) zipgrep -q "${pattern}" "${file}" && echo "${file}" ;;
		*) grep -l "${pattern}" "${file}" ;;
		esac
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
        epubgrep "$@"
fi
