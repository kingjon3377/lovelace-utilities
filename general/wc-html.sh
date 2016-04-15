#!/bin/sh
called_path=$_
wc_html() {
	for file in "$@";do
		printf "%s" "${file}:	"
		html2text --ignore-links --ignore-emphasis --ignore-images "${file}" | wc -w
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
# if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	wc_html "$@"
fi
