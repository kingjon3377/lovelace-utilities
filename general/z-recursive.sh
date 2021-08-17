#!/bin/bash
called_path="${BASH_SOURCE[0]}"
if [ -f "${called_path%/*}"/z-if-possible.sh  ];then
	# shellcheck source=./z-if-possible.sh
	. "${called_path%/*}"/z-if-possible.sh
elif [ -f ~/bin/z-if-possible.sh ];then
	# shellcheck source=./z-if-possible.sh
	. ~/bin/z-if-possible.sh || return 2
elif [ -f /usr/local/bin/z-if-possible.sh ];then
	# shellcheck source=./z-if-possible.sh
	. /usr/local/bin/z-if-possible.sh || return 2
else
	return 2
fi
z_recursive() {
	#shopt -s -q nullglob
	if [ -f "$1" ]; then
		z_if_possible "$1"
		return $?
	elif [ ! -d "$1" ]; then
		echo "$0: $1 is neither a regular file nor a directory" 1>&2
		return 1
	else
		echo Entering "$1" ...
		for xx in "${1}"/*; do
			if ! z_recursive "$xx"; then
				return 2
			fi
		done
		echo "Done in $1 ..."
	fi
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	z_recursive "$@"
fi
