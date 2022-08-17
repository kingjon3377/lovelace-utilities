#!/bin/sh
# If the filename given is not pure-ASCII, report this to stdout.
# TODO: Convert to a function as well?
if ! test -f "${1}" && ! test -d "${1}";then
	echo "${1} not found" 1>&2
fi
# shellcheck disable=SC2012
ls -d "${1}" | file -s - | grep -q -e '^/dev/stdin:[ 	]*ASCII text$' || echo "${1}: non-ASCII"
