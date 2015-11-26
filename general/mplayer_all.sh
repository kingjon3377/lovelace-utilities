#!/bin/sh
called_path=$_
mplayer_all_get_files() {
	for a in "$@"; do
		if [ -d "${a}" ]; then
			mplayer_all_get_files "${a}"/*
		elif [ -f "${a}" ]; then
			echo "${a}"
		fi
	done
}
mplayer_all() {
	mplayer $(mplayer_all_get_files "$@"|shuf)
}

# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	mplayer_all "$@"
fi
