#!/bin/sh
called_path=$_
find_largest_files() {
	du -aPS0 "$@" | sort -nrz -k 1 | sed -z -e 's:^[ 	]*[0-9]*[ 	]*::' | \
		xargs -0 -I arg "${called_path%/*}/size_file" arg | less
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	find_largest_files "$@"
fi
