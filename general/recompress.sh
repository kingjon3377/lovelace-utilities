#!/bin/sh
rc_called_path=$_
if [ -f ${rc_called_path%/*}/z-if-possible.sh  ];then
    . ${rc_called_path%/*}/z-if-possible.sh
elif [ -f ~/bin/z-if-possible.sh ];then
	. ~/bin/z-if-possible.sh || return 2
elif [ -f /usr/local/bin/z-if-possible.sh ];then
	. /usr/local/bin/z-if-possible.sh || return 2
else
	return 2
fi
recompress() {
	filename="${1}"
	size="$(stat -c "%s"l "${filename}")"
	free_space=$(df -P -B 1 "${filename}" | awk 'NR=2 { print $4 }')
	doubled=$((size * 3))
	if [ "${doubled}" -gt "${free_space}" ]; then
		echo "${0}: ${filename} looks too big to decompress here ..."
		return 0
	fi
	stat=$(stat "${filename}" | grep Links: | sed 's/^.*Links: //')
	if [ "$stat" -ne 1 ]; then
		echo "${0}: ${filename} has more than one link, skipping ..."
		return 0
	else
		case "${filename}" in
		*.gz)
#			base="$(dirname "${filename}")/$(basename "${filename}" .gz)"
			base="${filename%.gz}"
			decompress=gunzip ;;
		*.GZ)
#			base="$(dirname "${filename}")/$(basename "${filename}" .GZ)"
			base="${filename%.GZ}"
			decompress=gunzip ;;
		*.bz2)
#			base="$(dirname "${filename}")/$(basename "${filename}" .bz2)"
			base="${filename%.bz2}"
			decompress=bunzip2 ;;
		*.BZ2)
#			base="$(dirname "${filename}")/$(basename "${filename}" .BZ2)"
			base="${filename%.BZ2}"
			decompress=bunzip2 ;;
		*.rz)
#			base="$(dirname "${filename}")/$(basename "${filename}" .rz)"
			base="${filename%.rz}"
			decompress=runzip ;;
		*.RZ)
#			base="$(dirname "${filename}")/$(basename "${filename}" .RZ)"
			base="${filename%.RZ}"
			decompress=runzip ;;
		*.lrz)
#			base="$(dirname "${filename}")/$(basename "${filename}" .lrz)"
			base="${filename%.lrz}"
			decompress="lrunzip -D" ;;
		*.LRZ)
#			base="$(dirname "${filename}")/$(basename "${filename}" .LRZ)"
			base="${filename%.LRZ}"
			decompress="lrunzip -D" ;;
		*.xz)
			base="${filename%.xz}"
			decompress=unxz ;;
		*.XZ)
			base="${filename%.XZ}"
			decompress=unxz ;;
		*.tgz)
#			base="$(dirname "${filename}")/$(basename "${filename}" .tgz).tar"
			base="${filename%.tgz}.tar"
			decompress=gunzip ;;
		*.TGZ)
#			base="$(dirname "${filename}")/$(basename "${filename}" .TGZ).tar"
			base="${filename%.TGZ}.tar"
			decompress=gunzip ;;
		*.tbz2)
#			base="$(dirname "${filename}")/$(basename "${filename}" .tbz2).tar"
			base="${filename%.tbz2}.tar"
			decompress=bunzip2 ;;
		*.TBZ2)
#			base="$(dirname "${filename}")/$(basename "${filename}" .TBZ2).tar"
			base="${filename%.TBZ2}.tar"
			decompress=bunzip2 ;;
		*)
			echo "${0}: I don't know how to handle ${filename}" 
			return 0 ;;
		esac
		if [ -e "${base}" ]; then
			echo "${0}: ${base} exists, refusing to decompress ..."
			return 0
		elif ! ${decompress} "${filename}"; then
			return 1
		fi
	fi
	z-if-possible "${base}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${rc_called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	recompress "$@"
fi
