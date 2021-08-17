#!/bin/bash
# TODO: Remove this script or adapt to Opus; Speex is almost never what one wants anymore
speex_concat() {
	if [ $# -lt 2 ]; then
		echo "Usage: speex_concat final.spx first.mp3 [second.mp3 ...]"
		return 1
	fi
	if [ "${SPXC_EXECUTED:-false}" != "true" ];then
		echo "Beware: don't call speex_concat again in this shell until"
		echo "this run finishes, or temporary files might get clobbered"
	fi
	SPC_IONICE_CMD=${SPC_NO_IONICE:-}
	if [ -z "${SPC_NO_IONICE}" ]; then
		SPC_IONICE_CMD="${SPC_IONICE_CMD:-ionice -c 3}"
	else
		SPC_IONICE_CMD="${SPC_IONICE_CMD:-command}"
	fi
	final="${1}"
	shift
	${SPC_IONICE_CMD} mp3wrap tmp_$$.mp3 "$@"
	${SPC_IONICE_CMD} ffmpeg -hide_banner -i tmp_$"${BASH_SOURCE[0]}"MP3WRAP.mp3 -acodec copy all_$$.mp3 && \
		rm tmp_$"${BASH_SOURCE[0]}"MP3WRAP.mp3
	${SPC_IONICE_CMD} id3cp "${1}" all_$$.mp3
	${SPC_IONICE_CMD} ffmpeg -hide_banner -i all_$$.mp3 -acodec speex "${final}"
	retval=$?
	rm all_$$.mp3
	return "${retval}"
}
if [ "${0}" = "${BASH_SOURCE[0]}" ]; then
	export SPXC_EXECUTED=true
	speex_concat "$@"
fi
