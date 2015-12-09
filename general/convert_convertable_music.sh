#!/bin/sh
ccm_called_path=$_
. ${ccm_called_path%/*}/find_convertable_music.sh
. ${ccm_called_path%/*}/play_possibly_remove.sh
convert_convertable_music() {
	for a in $(find_convertable_music); do
		orig="${a}"
		case "${a}" in
#			*mp3) BASE="$(dirname "${a}")/$(basename "${a}" .mp3)" ;;
			*mp3) BASE="${a%.mp3}";;
#			*flac) BASE="$(dirname "${a}")/$(basename "${a}" .flac)" ;;
			*flac) BASE="${a%.flac}" ;;
#			*wma) BASE="$(dirname "${a}")/$(basename "${a}" .wma)" ;;
			*wma) BASE="${a%.wma}" ;;
#			*wav) BASE="$(dirname "${a}")/$(basename "${a}" .wav)" ;;
			*wav) BASE="${a%.wav}" ;;
			*) echo "Unknown file extension on ${a}"; return 1 ;;
		esac
		dir2ogg --mp3-decoder=mplayer "${orig}" || return $?
		echo "About to play the OGG; type \"n\" at the next prompt if you want to keep it."
		play_possibly_remove "${BASE}.ogg"
		if [ -e "${BASE}.ogg" ]; then
			rm -i "${orig}"
		fi
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${ccm_called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	convert_convertable_music
fi
