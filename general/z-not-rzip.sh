#!/bin/sh
called_path=$_
z_not_rzip() {
	filename="$1"
	if [ -e "$filename".gz ] || [ -e "$filename".bz2 ]; then
		echo Refusing to overwrite existing archives, skipping ... 1>&2
		return 0
	fi
#	base="$(basename "${filename}")"
#	if [ "${base}" != "$(basename "$filename" .gz)" ] || \
#			[ "${base}" != "$(basename "$filename" .bz2)" ] || \
#			[ "${base}" != "$(basename "$filename" .tgz)" ] || \
#			[ "${base}" != "$(basename "$filename" .tbz2)" ]; then
	case "${filename}" in
	*.gz | *.bz2 | *.tgz | *.tbz2)
		echo Looks like one of my output formats, skipping ... 1>&2
		return 0 ;;
	esac
	cmd="${0##*/}"
	if [ "$(stat -c "%h" "${filename}")" -ne 1 ]; then
		echo "${cmd}: ${1} has more than one link, skipping ..." 1>&2
		return 0
	fi
	raw_size=$("stat" -c "%s" "$filename")
	gzip -9 < "${filename}" > "$1".gz
	gzip_size=$("stat" -c "%s" "$1".gz)
	rm "$1".gz
	bzip2 -k "$1"
	bzip_size="$("stat" -c "%s" "$1".bz2)"
	rm "$1".bz2
	if [ "$raw_size" -le "$gzip_size" ] && \
			[ "$raw_size" -le "$bzip_size" ]; then
		echo "leaving $filename be ..."
	elif [ "$gzip_size" -le "$raw_size" ] && \
			[ "$gzip_size" -le "$bzip_size" ] ; then
		gzip -9 "$filename"
		echo "gzipping $filename ..."
	elif [ "$bzip_size" -le "$raw_size" ] && \
			[ "$bzip_size" -le "$gzip_size" ] ; then
		bzip2 "$filename"
		echo "bzipping $filename ..."
	else
		echo "$0: Shouldn't get here!"
		beep
		return 1
	fi
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	z_not_rzip "$@"
fi
