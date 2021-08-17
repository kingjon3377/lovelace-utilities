#!/bin/bash
called_path="${BASH_SOURCE[0]}"
find_largest_files() {
	du -aPS0 "$@" | sort -nrz -k 1 | sed -z -e 's:^[ 	]*[0-9]*[ 	]*::' | \
		xargs -0 -I arg "${called_path%/*}/size_file" arg | less
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	find_largest_files "$@"
fi
