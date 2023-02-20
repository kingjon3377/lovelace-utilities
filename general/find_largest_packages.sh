#!/bin/bash
find_largest_packages() {
	qsize -k -f -C | sed -e 's/^\([^:]*\): [0-9]* files, [0-9]* non-files, \([0-9]*\) KiB$/\2	\1/' | sort -nr | less
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	find_largest_packages "$@"
fi
