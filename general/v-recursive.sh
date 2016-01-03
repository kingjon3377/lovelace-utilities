#!/bin/sh
vr_called_path=$_
# shellcheck source=./v-if-possible.sh
. ${vr_called_path%/*}/v-if-possible.sh
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
			v_recursive "$xx"
			if [ $? -ne 0 ]; then
				return 2
			fi
		done
	fi
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${vr_called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        v-recursive "$@"
fi
