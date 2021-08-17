#!/bin/bash
lrunzip_tricky() {
#	[ "$(basename "${1}" .lrz)" = "$(basename "${1}")" ] && return 1
	[ "${1%.lrz}" = "${1}" ] && return 1
#	[ -e "$(dirname "${1}")"/"$(basename "${1}" .lrz)" ] && return 2
	[ -e "${1%.lrz}" ] && return 2
	${GLOBAL_LRUNZIP:-/usr/bin/lrunzip} -D "${1}" && return 0
#	rm "$(dirname "${1}")"/"$(basename "${1}" .lrz)"
	rm "${1%.lrz}"
	${LOCAL_LRUNZIP:-${HOME}/lrzip/bin/lrunzip} -D "${1}"
	return $?
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	lrunzip_tricky "$@"
fi
