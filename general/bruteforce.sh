#!/bin/sh
called_path=$_
bruteforce() {
	case "$1" in
		*rar) while read -r pass; do
				unrar t "$1" -p"$pass" && unrar x "$1" -p"${pass}" && echo "Working password: \"${pass}\"" && return 0
			done < "$2"; return 2;;
		*zip) while read -r pass; do
				unzip -t -P "$pass" "$1" && unzip -P "$pass" "$1" && echo "Working password: \"${pass}\"" && return 0
			done < "$2"; return 2;;
		*) echo "Unsupported archive format"
			return 1 ;;
	esac
}
multiple_bruteforce() {
	pass_file="$1"
	shift
	for a in "$@"; do
		if [ -d "${a}" ]; then 
			multiple_bruteforce "${pass_file}" "${a}"/* && return
		else
			bruteforce "${a}" "${pass_file}" && return
		fi
	done
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        bruteforce "$@"
fi
