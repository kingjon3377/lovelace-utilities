#!/bin/sh
cm_called_path=$_
check_mp3() {
	if find /media/mp3 -maxdepth 0 -type d -empty | read -r; then
		echo "Player not mounted or empty"
		return 1
	fi
	cd /media/mp3 || return 1
	find ./*/ -type f | while read -r file;do
		base="${file%.mp3}"
		any=false
		for ext in mp3 flac ogg wma rm m4a;do
			if test -f "/home/kingjon/music/favorites/${base}.${ext}"; then
				any=true
				break
			fi
		done
		if test ${any} = false; then
			echo "${file} no longer present in favorites"
		fi
	done
	cd /home/kingjon/music/favorites || return 2
	find ./*/ -type f | while read -r file;do
		case "${file}" in
		*.mp3) target=${file} ;;
		*.wma) target=${file%%.wma}.mp3 ;;
		*.m4a) target=${file%%.m4a}.mp3 ;;
		*.ogg) target=${file%%.ogg}.mp3 ;;
		*.flac) target=${file%%.flac}.mp3 ;;
		*.rm) target=${file%%.rm}.mp3 ;;
		*) echo "Unhandled extension on ${file}"; continue ;;
		esac
		test -f "/media/mp3/${target}" || echo "${file} missing from player"
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${cm_called_path}" = "$0" ] && check_mp3 "$@"
#[ "${BASH_SOURCE}" = "$0" ] && check_mp3 "$@"
