#!/bin/bash
ratpoison_renumber() {
	if ! test $# -eq 2; then
		echo "Usage: ratpoison-renumber new old" 1>&2
		return
	fi
	ratpoison --command="number ${1} ${2}"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	ratpoison_renumber "$@"
fi
