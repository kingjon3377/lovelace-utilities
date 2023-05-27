#!/bin/bash
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
			[ -e "${filename}".lz ] || [ -e "${filename}".rz ] \
			|| [ -e "${filename}".lrz ]; then
		echo Refusing to overwrite existing archives, skipping ... 1>&2
		return 0
	fi
	case "${filename}" in
	*.gz | *.bz2 | *.lz | *.lzma | *.rz | *.tgz | *.tbz2 | *.tlz | *.lrz)
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
	lzip -9 -k "${filename}"
	lz_size="$(stat -c "%s" "${filename}".lz)"
	rm "${filename}".lz
	if [ "$SKIP_RZIP" = true ]; then
		rzip_size="$(( raw_size * raw_size ))"
	else
		rzip -9 -k "${filename}"
		rzip_size="$(stat -c "%s" "${filename}".rz)"
		rm "${filename}".rz
	fi
	lrzip -z -q -N 0 "${filename}"
	lrzip_size="$(stat -c "%s" "${filename}".lrz)"
	rm "${filename}".lrz
	if [ "$raw_size" -le "$gzip_size" ] && [ "$raw_size" -le "$bzip_size" ] && \
			[ "$raw_size" -le "$lz_size" ] && [ "$raw_size" -le "$rzip_size" ] && \
			[ "$raw_size" -le "$lrzip_size" ]
	then
		echo "Leaving ${filename} be ..."
	elif [ "$gzip_size" -le "$raw_size" ] && [ "$gzip_size" -le "$bzip_size" ] && \
			[ "$gzip_size" -le "$lz_size" ] && [ "$gzip_size" -le "$rzip_size" ] && \
			[ "$gzip_size" -le "$lrzip_size" ]; then
		echo "gzipping ${filename} ..."
		gzip -9 "${filename}"
	elif [ "$bzip_size" -le "$raw_size" ] && [ "$bzip_size" -le "$gzip_size" ] && \
			[ "$bzip_size" -le "$lz_size" ] && [ "$bzip_size" -le "$rzip_size" ] && \
			[ "$bzip_size" -le "$lrzip_size" ]; then
		echo "bzipping ${filename} ..."
		bzip2 -f "${filename}"
	elif [ "$lz_size" -le "$raw_size" ] && [ "$lz_size" -le "$gzip_size" ] && \
			[ "$lz_size" -le "$bzip_size" ] && [ "$lz_size" -le "$rzip_size" ] && \
			[ "$lz_size" -le "$lrzip_size" ]; then
		echo "lzipping ${filename} ..."
		lzip -9 "${filename}"
	elif [ "$rzip_size" -le "$raw_size" ] && [ "$rzip_size" -le "$gzip_size" ] && \
			[ "$rzip_size" -le "$bzip_size" ] && [ "$rzip_size" -le "$lz_size" ] && \
			[ "$rzip_size" -le "$lrzip_size" ]; then
		echo "rzipping ${filename} ..."
		rzip -9 "${filename}"
	elif [ "$lrzip_size" -le "$raw_size" ] && [ "$lrzip_size" -le "$gzip_size" ] && \
			[ "$lrzip_size" -le "$bzip_size" ] && [ "$lrzip_size" -le "$lz_size" ] && \
			[ "$lrzip_size" -le "$rzip_size" ]; then
		echo "lrzipping ${filename} ..."
		lrzip -z -q -D -N 0 "${filename}"
	else
		echo "z_if_possible: Shouldn't get here!"
		beep
		return 1
	fi
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	z_if_possible "$@"
fi
