#!/bin/sh
called_path=$_
z_if_possible() {
	if [ $# -ge 2 ] && [ "$2" = "--skip-rzip" ]; then
		SKIP_RZIP=true
	else
		SKIP_RZIP=${SKIP_RZIP:-false}
	fi
	filename="$1"
	if ! [ -f "${filename}" ]; then
		echo "${filename} not present. Skipping ..." 1>&2
		return 0
	fi
	if [ -e "${filename}".gz ] || [ -e "${filename}".bz2 ] || \
			[ -e "${filename}".xz ] || [ -e "${filename}".rz ] \
			|| [ -e "${filename}".lrz ]; then
		echo Refusing to overwrite existing archives, skipping ... 1>&2
		return 0
	fi
	case "${filename}" in
	*.gz | *.bz2 | *.xz | *.lzma | *.rz | *.tgz | *.tbz2 | *.txz | *.tlz | *.lrz)
		echo Looks like one of my output formats, skipping ... 1>&2
		return 0 ;;
	esac
	if [ "$(stat -c "%h" "${filename}")" -ne 1 ]; then
		echo "z_if_possible: ${filename} has more than one link, skipping ..." 1>&2
		return 0
	fi
	raw_size="$(stat -c "%s" "${filename}")"
	gzip -9 < "${filename}" > "${filename}".gz
	gzip_size="$(stat -c "%s" "${filename}".gz)"
	rm "${filename}".gz
	bzip2 -f -k "${filename}"
	bzip_size="$(stat -c "%s" "${filename}".bz2)"
	rm "${filename}".bz2
	xz -9 -f -k -S .xz "${filename}"
	xz_size="$(stat -c "%s" "${filename}".xz)"
	rm "${filename}".xz
	if [ $SKIP_RZIP = true ]; then
		rzip_size="$(( raw_size * raw_size ))"
	else
		rzip -9 -k "${filename}"
		rzip_size="$(stat -c "%s" "${filename}".rz)"
		rm "${filename}".rz
	fi
	lrzip -q -N 0 "${filename}"
	lrzip_size="$(stat -c "%s" "${filename}".lrz)"
	rm "${filename}".lrz
	if [ "$raw_size" -le "$gzip_size" ] && [ "$raw_size" -le "$bzip_size" ] && \
			[ "$raw_size" -le "$xz_size" ] && [ "$raw_size" -le "$rzip_size" ] && \
			[ "$raw_size" -le "$lrzip_size" ]
	then
		echo "Leaving ${filename} be ..."
	elif [ "$gzip_size" -le "$raw_size" ] && [ "$gzip_size" -le "$bzip_size" ] && \
			[ "$gzip_size" -le "$xz_size" ] && [ "$gzip_size" -le "$rzip_size" ] && \
			[ "$gzip_size" -le "$lrzip_size" ]; then
		echo "gzipping ${filename} ..."
		gzip -9 "${filename}"
	elif [ "$bzip_size" -le "$raw_size" ] && [ "$bzip_size" -le "$gzip_size" ] && \
			[ "$bzip_size" -le "$xz_size" ] && [ "$bzip_size" -le "$rzip_size" ] && \
			[ "$bzip_size" -le "$lrzip_size" ]; then
		echo "bzipping ${filename} ..."
		bzip2 -f "${filename}"
	elif [ "$xz_size" -le "$raw_size" ] && [ "$xz_size" -le "$gzip_size" ] && \
			[ "$xz_size" -le "$bzip_size" ] && [ "$xz_size" -le "$rzip_size" ] && \
			[ "$xz_size" -le "$lrzip_size" ]; then
		echo "xzipping ${filename} ..."
		xz -9 -f -S .xz "${filename}"
	elif [ "$rzip_size" -le "$raw_size" ] && [ "$rzip_size" -le "$gzip_size" ] && \
			[ "$rzip_size" -le "$bzip_size" ] && [ "$rzip_size" -le "$xz_size" ] && \
			[ "$rzip_size" -le "$lrzip_size" ]; then
		echo "rzipping ${filename} ..."
		rzip -9 "${filename}"
	elif [ "$lrzip_size" -le "$raw_size" ] && [ "$lrzip_size" -le "$gzip_size" ] && \
			[ "$lrzip_size" -le "$bzip_size" ] && [ "$lrzip_size" -le "$xz_size" ] && \
			[ "$lrzip_size" -le "$rzip_size" ]; then
		echo "lrzipping ${filename} ..."
		lrzip -q -D -N 0 "${filename}"
	else
		echo "z_if_possible: Shouldn't get here\!"
		beep
		return 1
	fi
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        z_if_possible "$@"
fi
