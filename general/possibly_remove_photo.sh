#!/bin/sh
called_path=$_
possibly_remove_photo() {
	for a in "$@"; do
		xzgv "${a}" &
		rm -i "${a}"
		wait
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        possibly_remove_photo "$@"
fi
