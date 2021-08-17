#!/bin/bash
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
	# TODO: Make mplayer_all_get_files quote its output
	# But whether the files are quoted or not, they have to be separated by the
	# shell
	# shellcheck disable=SC2046
	mplayer $(mplayer_all_get_files "$@"|shuf)
}

if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	mplayer_all "$@"
fi
