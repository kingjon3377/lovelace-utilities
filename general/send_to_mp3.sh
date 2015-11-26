#!/bin/sh
stm_called_path=$_
send_to_mp3() {
	for file in "$@";do
		test -d "/media/mp3/${file%/*}" || mkdir -p "/media/mp3/${file%/*}"
		test -f "${file}" || continue
		case "${file}" in
		*mp3) test -f /media/mp3/"${file}" && continue; cp -i "${file}" /media/mp3/"${file}"; continue ;;
		*wma) base=${file%%.wma} ;;
		*m4a) base=${file%%.m4a} ;;
		*ogg) base=${file%%.ogg} ;;
		*flac) base=${file%%.flac} ;;
		*.rm) base=${file%%.rm} ;;
		*) echo "Unhandled extension on ${file}" ; continue ;;
		esac
		test -f "/media/mp3/${base}.mp3" && continue
#		ffmpeg -i "${file}" -vn -acodec mp2 /media/mp3/"${base}.mp3"
		ffmpeg -i "${file}" -vn /media/mp3/"${base}.mp3"
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
#[ "${stm_called_path}" = "$0" ] && send_to_mp3 "$@"
[ "${BASH_SOURCE}" = "$0" ] && send_to_mp3 "$@"
