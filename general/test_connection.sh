#!/bin/sh
called_path=$_
test_connection() {
	for a in 172.16.42.1 8.8.8.8 google.com ; do
		ping -c 1 "${a}" || { /sbin/route -n; return; }
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        test_connection "$@"
fi
