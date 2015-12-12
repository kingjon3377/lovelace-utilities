#!/bin/sh
cm_called_path=$_
if [ "${cm_called_path}" = "$0" ]; then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME}" ] && [ -d "${XDG_CONFIG_HOME}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME}/lovelace-utilities/config" ]; then
        . "${XDG_CONFIG_HOME}/lovelace-utilities/config"
    else
        MP3_PLAYER=/media/mp3
        MUSIC_COLLECTION=/home/kingjon/music/favorites
    fi
fi
check_mp3() {
	if find "${MP3_PLAYER}" -maxdepth 0 -type d -empty | read -r; then
		echo "Player not mounted or empty"
		return 1
	fi
	cd "${MP3_PLAYER}" || return 1
	find ./*/ -type f | while read -r file;do
		base="${file%.mp3}"
		any=false
        # TODO: Make extensions configurable; note that doing this without
        # introducing shellcheck warnings would require an array, which is a
        # bashism.
		for ext in mp3 flac ogg wma rm m4a;do
			if test -f "${MUSIC_COLLECTION}/${base}.${ext}"; then
				any=true
				break
			fi
		done
		if test ${any} = false; then
			echo "${file} no longer present in favorites"
		fi
	done
	cd "${MUSIC_COLLECTION}" || return 2
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
		test -f "${MP3_PLAYER}/${target}" || echo "${file} missing from player"
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
[ "${cm_called_path}" = "$0" ] && check_mp3 "$@"
#[ "${BASH_SOURCE}" = "$0" ] && check_mp3 "$@"
