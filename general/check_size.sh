#!/bin/bash
# Print the size of a file and the media parameters (width, height, and codecs)
# contributing to that size. Useful for identifying low-hanging fruit for
# transcoding to reduce disk usage.
check_size () { 
    du -h "$1" && midentify "$1" | grep -i -e width -e height -e codec
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	check_size "$@"
fi
