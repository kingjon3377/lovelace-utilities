#!/bin/bash
fbi_filter() {
	grep -v \
		-e '^using "DejaVu Sans Mono-16", pixelsize=16.67 file=/usr/share/fonts/dejavu/DejaVuSansMono.ttf$' \
		-e '^map: vt[0-9]* => fb[0-9]*$'
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	fbi_filter "$@"
fi
