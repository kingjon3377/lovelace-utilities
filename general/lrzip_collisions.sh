#!/bin/bash
lrzip_collisions() {
#	[ "$(basename "$1" .lrz)" = "$(basename "$1")" ] && return 1
	[ "${1%.lrz}" = "${1}" ] && return 1
#	[ -e "$(dirname "$1")"/"$(basename "$1" .lrz)" ] || return 2
	[ -e "${1%.lrz}" ] || return 2
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	lrzip_collisions "$@"
fi
