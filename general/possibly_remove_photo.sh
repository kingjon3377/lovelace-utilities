#!/bin/bash
# TODO: What if DISPLAY unset?
possibly_remove_photo() {
	for a in "$@"; do
		xzgv "${a}" &
		rm -i "${a}"
		wait
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	possibly_remove_photo "$@"
fi
