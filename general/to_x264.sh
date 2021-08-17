#!/bin/bash
# TODO: Rename to compress_video.sh and support VP9 and whatever its successor is (but leave h264 the default,
# as VP9 encoding is *significantly* slower)
to_x264_each() {
	filename="$(realpath "${1}")"
	filepath="${filename%/*}"
	tempdir="$(mktemp -d)"
	OLD_PWD="${PWD}"
	cd "${tempdir}" || return 1
	case "${filename}" in
	*[Aa][Vv][Ii].gz)
		base="${filename%.gz}"
		decompress=gunzip ;;
	*[Aa][Vv][Ii].GZ)
		base="${filename%.GZ}"
		decompress=gunzip ;;
	*[Aa][Vv][Ii].bz2)
		base="${filename%.bz2}"
		decompress=bunzip2 ;;
	*[Aa][Vv][Ii].BZ2)
		base="${filename%.BZ2}"
		decompress=bunzip2 ;;
	*[Aa][Vv][Ii].rz)
		base="${filename%.rz}"
		decompress=runzip ;;
	*[Aa][Vv][Ii].RZ)
		base="${filename%.RZ}"
		decompress=runzip ;;
	*[Aa][Vv][Ii].lrz)
		base="${filename%.lrz}"
		decompress="lrunzip -D" ;;
	*[Aa][Vv][Ii].LRZ)
		base="${filename%.LRZ}"
		decompress="lrunzip -D" ;;
	*[Aa][Vv][Ii].xz)
		base="${filename%.xz}"
		decompress=unxz ;;
	*[Aa][Vv][Ii].lz)
		base="${filename%.lz}"
		decompress="lzip -d" ;;
	*[Aa][Vv][Ii].XZ)
		base="${filename%.XZ}"
		decompress=unxz ;;
	*[Aa][Vv][Ii].LZ)
		base="${filename%.LZ}"
		decompress="lzip -d" ;;
	*)
		echo "${0}": I don\'t know how to handle "${filename}" 
		return 0 ;;
	esac
	pathless="${filename##*/}"
	pathless_base="${base##*/}"
	final="${pathless_base%.[Aa][Vv][Ii]}.mp4"
	{ cp "${filename}" .&&${decompress} "${pathless}" && \
		ffmpeg -hide_banner -i "${pathless_base}" -vcodec libx264 -f mp4 -acodec libfaac "${final}" && \
		echo "Press enter to test converted video ..." && \
		read -r && \
		play_possibly_remove.sh "${final}"; } || return $?
	if [ -f "${final}" ]; then
		{ z-if-possible.sh "${final}" && du -h "${filename}" "${final}"* "${pathless_base}" && \
			rm "${pathless_base}" && mv -i "${final}"* "${filepath}" && rm -i "${filename}" && \
			cd "${OLD_PWD}" && rmdir "${tempdir}"; } || return $?
	else
		{ rm "${pathless_base}" && cd "${OLD_PWD}" && rmdir "${tempdir}"; } || return $?
	fi
}
to_x264() {
	for arg in "$@"; do
		to_x264_each "${arg}"
	done
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	to_x264 "$@"
fi
