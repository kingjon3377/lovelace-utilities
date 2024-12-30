#!/bin/bash
cv_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cv_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
# shellcheck source=./play_possibly_remove.sh
. "${cv_called_path%/*}/play_possibly_remove.sh"
get_codec() {
    if type midentify > /dev/null 2>&1; then
        midentify "${1}" | grep AUDIO_CODEC | sed 's/^ID_AUDIO_CODEC=//'
    elif type mediainfo > /dev/null 2>&1;then
        mediainfo --Output='Audio;%CodecID%' "${1}"
    elif type ffprobe > /dev/null 2>&1; then
        # TODO: Breaks if any tags include 'Audio:'
        ffprobe "${1}" 2>&1 | grep Audio | sed 's@^.*Audio: \([^,]*\),.*$@\1@'
    fi
}
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
			*flv) BASE="${1%.flv}"
				codec=$(get_codec "${orig}")
				case "${codec}" in
					ffopus|A_OPUS|opus) DEST="${BASE}.opus" ;;
					ffvorbis|A_VORBIS|vorbis) DEST="${BASE}.ogg" ;;
					ffaac|mp4a-40-*|aac) DEST="${BASE}.m4a" ;;
					mpg123|mp3) DEST="${BASE}.mp3" ;;
					*) echo "Unknown codec ${codec} in flv"; return 3 ;;
				esac ;;
			*mp4) BASE="${1%.mp4}" DEST="${BASE}.m4a" ;;
			*webm) BASE="${1%.webm}" DEST="${BASE}.ogg" ;;
			*3gpp) BASE="${1%.3gpp}" DEST="${BASE}.m4a" ;;
			*3gp) BASE="${1%.3gp}" DEST="${BASE}.m4a" ;;
			*mkv) BASE="${1%.mkv}"
				codec=$(get_codec "${orig}")
				case "${codec}" in
					ffopus|A_OPUS|opus) DEST="${BASE}.opus" ;;
					ffvorbis|A_VORBIS|vorbis) DEST="${BASE}.ogg" ;;
					ffaac|mp4a-40-*|aac) DEST="${BASE}.m4a" ;;
					mpg123|mp3) DEST="${BASE}.mp3" ;;
					*) echo "Unknown codec ${codec} in mkv"; return 3 ;;
				esac ;;
			*) echo "Unknown extension"; return 2 ;;
		esac
		if [ -e "${DEST}" ]; then
			echo "${DEST} already exists, skipping ..."
			return
		fi
		ffmpeg -hide_banner -i "${orig}" -vn -acodec copy "${DEST}" || return $?
		echo "About to play the extracted audio; type \"n\" at the next prompt if you want to keep it."
		play_possibly_remove "${DEST}"
		if test -e "${DEST}"; then
			echo "Type \"n\" at the next prompt to keep the original file."
			rm -i "${orig}"
		fi
	fi
}
[ "${BASH_SOURCE[0]}" = "$0" ] && convert_video "$@"
