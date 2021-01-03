#!/bin/sh
rc_called_path=$_
if [ -f "${rc_called_path%/*}/z-if-possible.sh"  ];then
# shellcheck source=./z-if-possible.sh
    . "${rc_called_path%/*}/z-if-possible.sh"
elif [ -f "${HOME}/bin/z-if-possible.sh" ];then
# shellcheck source=./z-if-possible.sh
	. "${HOME}/bin/z-if-possible.sh" || return 2
elif [ -f /usr/local/bin/z-if-possible.sh ];then
# shellcheck source=./z-if-possible.sh
	. /usr/local/bin/z-if-possible.sh || return 2
else
	return 2
fi
recompress() {
	filename="${1}"
	if ! test -f "${filename}"; then
		return 0;
	fi
	size="$(stat -c "%s" "${filename}")"
	free_space=$(df -P -B 1 "${filename}" | tail -n 1 | awk 'NR=2 { print $4 }')
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
		*.[gG][Zz])
			base="${filename%.[gG][zZ]}"
			decompress=gunzip ;;
		*.[bB][zZ]2)
			base="${filename%.[bB][zZ]2}"
			decompress=bunzip2 ;;
		*.[rR][zZ])
			base="${filename%.[rR][zZ]}"
			decompress=runzip ;;
		*.[lL][rR][zZ])
			base="${filename%.[lL][rR][zZ]}"
			decompress="lrunzip -D" ;;
		*.[xX][zZ])
			base="${filename%.[xX][zZ]}"
			decompress=unxz ;;
		*.[Ll][Zz][Mm][Aa])
			base="${filename%.[Ll][Zz][Mm][Aa]}"
			decompress=unxz ;;
		*.[tT][Gg][Zz])
			base="${filename%.[Tt][Gg][Zz]}.tar"
			decompress=gunzip ;;
		*.[Tt][Bb][Zz]2)
			base="${filename%.[Tt][Bb][Zz]2}.tar"
			decompress=bunzip2 ;;
		*.[Tt][Xx][Zz])
			base="${filename%.[Tt][Xx][Zz]}.tar"
			decompress=unxz ;;
		*.[Ll][Zz])
			base="${filename%.[Ll][Zz]}"
			decompress="lzip -d" ;;
		*.[Tt][Ll][Zz])
			base="${filename%.[Tt][Ll][Zz]}.tar"
			decompress="lzip -d" ;;
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
	z_if_possible "${base}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${rc_called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	recompress "$@"
fi
