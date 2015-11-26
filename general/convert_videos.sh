#!/bin/sh
cvs_called_path=$_
. ~/bin/play_possibly_remove.sh
convert_videos() {
	find . -xdev -name sermons -prune -o -type f -iname \*.flv -print | while read -r a; do
		orig="${a}"
#		BASE="$(dirname "${a}")/$(basename "${a}" .flv)"
		BASE="${a%.flv}"
		if [ -e "${BASE}.ogg" ] ; then
			echo "${BASE}.ogg already exists, skipping ..."
			continue
		fi
		ffmpeg2theora --novideo "${orig}" || return $?
		mv -i "${BASE}.ogv" "${BASE}.ogg" || return 1
		echo "About to play the OGG; type \"n\" at the next prompt if you want to keep it."
		play_possibly_remove "${BASE}.ogg"
		[ -e "${BASE}.ogg" ] && rm -i "${orig}"
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${cvs_called_path}" = "$0" ] && convert_videos "$@"
# [ "${BASH_SOURCE}" = "$0" ] && convert_videos
