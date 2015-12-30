#!/bin/sh
stm_called_path=$_
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config"
    else
        MP3_PLAYER=/media/mp3
    fi
fi
send_to_mp3() {
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
#		ffmpeg -i "${file}" -vn -acodec mp2 /media/mp3/"${base}.mp3"
		ffmpeg -i "${file}" -vn "${MP3_PLAYER}/${base}.mp3"
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
#[ "${stm_called_path}" = "$0" ] && send_to_mp3 "$@"
[ "${BASH_SOURCE}" = "$0" ] && send_to_mp3 "$@"
