#!/bin/sh
called_path=$_
lrzip_collisions() {
#	[ "$(basename "$1" .lrz)" = "$(basename "$1")" ] && return 1
	[ "${1%.lrz}" = "${1}" ] && return 1
#	[ -e "$(dirname "$1")"/"$(basename "$1" .lrz)" ] || return 2
	[ -e "${1%.lrz}" ] || return 2
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	lrzip_collisions "$@"
fi
