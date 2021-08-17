#!/bin/bash
wc_html() {
	for file in "$@";do
		printf "%s" "${file}:	"
		html2text --ignore-links --ignore-emphasis --ignore-images "${file}" | wc -w
	done
}
 if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	wc_html "$@"
fi
