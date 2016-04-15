#!/bin/sh
called_path=$_
ratpoison_renumber() {
	if ! test $# -eq 2; then
		echo "Usage: ratpoison-renumber new old" 1>&2
		return
	fi
	ratpoison --command="number ${1} ${2}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	ratpoison_renumber "$@"
fi
