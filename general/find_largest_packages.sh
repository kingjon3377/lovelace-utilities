#!/bin/sh
called_path=$_
find_largest_packages() {
	qsize -a -k -f -C | sed -e 's/^\([^:]*\): [0-9]* files, [0-9]* non-files, \([0-9]*\) KB$/\2	\1/' | sort -nr | less
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	find_largest_packages "$@"
fi
