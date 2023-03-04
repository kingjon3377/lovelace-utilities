#!/bin/bash
# Convert the given media file to 48k/s-audio VBR Opus; after doing so, play
# the two files and ask the user to confirm replacing the old with the new (if
# the original is Opus already) or removing the old in favor of the new (if an
# MP3 or M4A).
reduce_bitrate() { 
	file="${1}"
	case "${file}" in 
		*.opus) base="${file%%.opus}" ; newfile="${base}.new.opus" ; domv=true ;;
		*.m4a) base="${file%%.m4a}" ; newfile="${base}.opus" ; domv=false ;;
		*.mp3) base="${file%%.mp3}" ; newfile="${base}.opus" ; domv=false ;;
		*) echo "Unexpected file extension in '${file}'" 1>&2 ; return 1 ;;
	esac
	ffmpeg -hide_banner -i "${file}" -c:a libopus -b:a 48k -vbr on "${newfile}" || return $?
	du -h "${file}" "${newfile}"
	echo "Press Enter to play files to compare"
	read -r
	mplayer "${file}" "${newfile}" || return $?
	case "${domv}" in 
		true) mv -i "${newfile}" "${file}" && test -f "${newfile}" && echo "Remove new file instead?" && rm -i "${newfile}" ;;
		false) echo "Remove original file, leaving new file?" && rm -i "${file}" && test -f "${file}" && \
			echo "Remove new file instead?" && rm -i "${newfile}" ;;
	esac
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	for file in "$@";do
		reduce_bitrate "${file}"
	done
fi
