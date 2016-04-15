#!/bin/sh
called_path=$_
speex_concat() {
	if [ $# -lt 2 ]; then
		echo "Usage: speex_concat final.spx first.mp3 [second.mp3 ...]"
		return 1
	fi
	if [ "${SPXC_EXECUTED:-false}" != "true" ];then
		echo "Beware: don't call speex_concat again in this shell until"
		echo "this run finishes, or temporary files might get clobbered"
	fi
	local SPC_IONICE_CMD
	if [ -z "${SPC_NO_IONICE}" ]; then
		SPC_IONICE_CMD="${SPC_IONICE_CMD:-ionice -c 3}"
	else
		SPC_IONICE_CMD="${SPC_IONICE_CMD:-command}"
	fi
	final="${1}"
	shift
	${SPC_IONICE_CMD} mp3wrap tmp_$$.mp3 "$@"
	${SPC_IONICE_CMD} ffmpeg -i tmp_$$_MP3WRAP.mp3 -acodec copy all_$$.mp3 && \
		rm tmp_$$_MP3WRAP.mp3
	${SPC_IONICE_CMD} id3cp "${1}" all_$$.mp3
	${SPC_IONICE_CMD} sox all_$$.mp3 -t wav -r 8000 - | ${SPC_IONICE_CMD} speexenc - "${final}"
	retval=$?
	rm all_$$.mp3
	return ${retval}
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${0}" = "${BASH_SOURCE[0]}" ]; then
	export SPXC_EXECUTED=true
	speex_concat "$@"
fi
