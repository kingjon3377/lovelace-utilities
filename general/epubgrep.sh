#!/bin/bash
epubgrep() {
	pattern=$1;shift
	for file in "$@";do
		case "${file}" in
			*.epub|*.zip) zipgrep -q "${pattern}" "${file}" && echo "${file}" ;;
			*) grep -l "${pattern}" "${file}" ;;
		esac
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	epubgrep "$@"
fi
