#!/bin/sh
called_path=$_
linkchecker() {
	linkchecker "$@" > linkchecker.out
	less linkchecker.out
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        linkchecker "$@"
fi
