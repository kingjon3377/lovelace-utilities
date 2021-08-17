#!/bin/bash
vr_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./v-if-possible.sh
. "${vr_called_path%/*}/v-if-possible.sh"
v_recursive() {
#	shopt -s -q nullglob
	if [ -f "$1" ]; then
		v_if_possible "$1"
		return 0
	elif [ ! -d "$1" ]; then
		echo "$0: $1 is neither a regular file nor a directory" 1>&2
		return 1
	else
		echo Entering "$1" ...
		for xx in "${1}"/*; do
			if ! v_recursive "$xx"; then
				return 2
			fi
		done
	fi
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	v_recursive "$@"
fi
