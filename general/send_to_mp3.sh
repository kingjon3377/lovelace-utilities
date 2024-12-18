#!/bin/bash
stm_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${stm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
send_to_mp3() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		MP3_PLAYER=${MP3_PLAYER:-/media/mp3}
	fi
	for file in "$@";do
		test -d "${MP3_PLAYER}/${file%/*}" || mkdir -p "${MP3_PLAYER}/${file%/*}"
		test -f "${file}" || continue
		case "${file}" in
			*mp3) test -f "${MP3_PLAYER}/${file}" && continue; cp -i "${file}" "${MP3_PLAYER}/${file}"; continue ;;
			*wma) base=${file%%.wma} ;;
			*m4a) base=${file%%.m4a} ;;
			*ogg) base=${file%%.ogg} ;;
			*flac) base=${file%%.flac} ;;
			*.rm) base=${file%%.rm} ;;
			*) echo "Unhandled extension on ${file}" ; continue ;;
		esac
		test -f "${MP3_PLAYER}/${base}.mp3" && continue
#		ffmpeg -hide_banner -i "${file}" -vn -acodec mp2 "${MP3_PLAYER}/mp3/"${base}.mp3"
		ffmpeg -hide_banner -i "${file}" -vn "${MP3_PLAYER}/${base}.mp3"
	done
}
[ "${BASH_SOURCE[0]}" = "$0" ] && send_to_mp3 "$@"
