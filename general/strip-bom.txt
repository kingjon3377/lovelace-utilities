#!/bin/sh
# Strip the byte-order marker from UTF-8 text.
called_path=$_
strip_bom() {
	sed -i -e '1s/^\xef\xbb\xbf//' "$@"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	strip_bom "$@"
fi
