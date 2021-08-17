#!/bin/bash
zwc() {
	for a in "$@";do
		printf "%s" "${a}: "
		zcat "${a}" 2> /dev/null | wc -l
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	zwc "$@"
fi
