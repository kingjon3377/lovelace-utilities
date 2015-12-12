#!/bin/sh
called_path=$_
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
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	find_bad_text "$@"
fi
