#!/bin/bash
#called_path=$_
count_files() {
	for arg in "$@";do
		find "${arg}" -maxdepth 1 -type f | wc -l | tr '\n' '	';echo "${arg}"
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
#if [ "${called_path}" = "$0" ]; then
if [ "${BASH_SOURCE}" = "$0" ]; then
        count_files "$@"
fi
