#!/bin/sh
called_path=$_
fbi_filter() {
	grep -v \
		-e '^using "DejaVu Sans Mono-16", pixelsize=16.67 file=/usr/share/fonts/dejavu/DejaVuSansMono.ttf$' \
		-e '^map: vt[0-9]* => fb[0-9]*$'
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	fbi_filter "$@"
fi
