#!/bin/bash
find_bad_text() {
	base=${1:-.}
	cmdline=""
	if [ $# -gt 1 ]; then
		shift
		for dir in "$@";do
			cmdline="${cmdline}-path ${dir} -prune -o "
		done
	fi
	find "${base}" "${cmdline}" -type f -exec file -N '{}' + | gawk '
		/: (HTML document, |)(ASCII|UTF-8 Unicode|ISO-8859) text(|, with very long lines)$/ { next }
		/\.css: assembler source, ASCII text$/ { next }
		/\.rtf: Rich Text Format data, version 1, ANSI$/ { next }
		/\.doc: Composite Document File V2 Document,/ { next }
		{ print }'
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	find_bad_text "$@"
fi
