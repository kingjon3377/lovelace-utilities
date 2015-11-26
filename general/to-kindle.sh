#!/bin/bash
called_path=$_
to_kindle() {
	dir=$(mktemp -d)
	mtpfs "${dir}" || return 1
	if test -d "${dir}/Books"; then
		for file in "$@"; do
			name="${file##*/}"
			case "${file}" in
			*.epub) base="${name%.epub}" ;;
			*.mobi) base="${name%.mobi}" ;;
			*.txt) base="${name%.txt}" ;;
			*.htm) base="${name%.htm}" ;;
			*.html) base="${name%.html}" ;;
			*) echo "Don't know how to handle ${file}" 1>&2 ; continue ;;
			esac
			if test -z "${KEEP_AZW3}"; then
				ebook-convert "${file}" \
						"${dir}/Books/${base}.azw3" || \
					{ echo "Failed to convert ${file}" 1>&2;
						return 2; }
			else
				ebook-convert "${file}" \
						"${HOME}/ff-epub/${base}.azw3" \
						|| \
					{ echo "Failed to convert ${file}" 1>&2;
						return 2; }
				mv -i "${HOME}/ff-epub/${base}.azw3" \
						"${dir}/Books/${base}.azw3" ||
					{ echo "Failed to transfer ${file}" 1>&2;
						continue; }
			fi
		done
	else
		echo "Books directory not found" 1>&2
	fi
	sleep 2
	fusermount -u "${dir}"
	rmdir "${dir}"
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
# [ "${called_path}" = "$0" ] && to_kindle "$@"
[ "${BASH_SOURCE}" = "$0" ] && to_kindle "$@"
