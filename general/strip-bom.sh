#!/bin/bash
# Strip the byte-order marker from UTF-8 text.
strip_bom() {
	sed -i -e '1s/^\xef\xbb\xbf//' "$@"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	strip_bom "$@"
fi
