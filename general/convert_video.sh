#!/bin/sh
cv_called_path=$_
. ${cv_called_path%/*}/play_possibly_remove.sh
convert_video() {
	if [ $# -gt 1 ]; then
		for arg in "$@";do
			convert_video "${arg}" || return $?
		done
	elif [ $# -eq 0 ]; then
		return 1
	else
		orig="${1}"
		case "${orig}" in
			*flv) BASE="${1%.flv}" DEST="${BASE}.ogg" ;;
			*mp4) BASE="${1%.mp4}" DEST="${BASE}.m4a" ;;
			*webm) BASE="${1%.webm}" DEST="${BASE}.ogg" ;;
			*3gpp) BASE="${1%.3gpp}" DEST="${BASE}.m4a" ;;
			*mkv) BASE="${1%.mkv}"
			codec=$(midentify "${1}" | grep AUDIO_CODEC | sed 's/^ID_AUDIO_CODEC=//')
			case "${codec}" in
			ffopus) DEST="${BASE}.ogg" ;;
			ffaac) DEST="${BASE}.m4a" ;;
			*) echo "Unknown codec ${codec} in mkv"; return 3 ;;
			esac ;;
			*) echo "Unknown extension"; return 2 ;;
		esac
		if [ -e "${BASE}.ogg" ]; then
			echo "${BASE}.ogg already exists, skipping ..."
			return
		fi
		ffmpeg -i "${orig}" -vn -acodec copy "${DEST}" || return $?
		echo "About to play the OGG; type \"n\" at the next prompt if you want to keep it."
		play_possibly_remove "${DEST}"
		if test -e "${DEST}"; then
			echo "About to play the original file; type \"n\" at the next prompt if you want to keep it."
			play_possibly_remove "${orig}"
		fi
	fi
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${cv_called_path}" = "$0" ] && convert_video "$@"
# [ "${BASH_SOURCE}" = "$0" ] && convert_video "$@"
