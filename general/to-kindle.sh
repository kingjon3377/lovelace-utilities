#!/bin/bash
cm_called_path="${BASH_SOURCE[0]}"
# shellcheck source=./lovelace-utilities-source-config.sh
. "${cm_called_path%/*}/lovelace-utilities-source-config.sh" || return 1
to_kindle() {
	lovelace_utilities_source_config
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		EBOOK_INTERIM_STORAGE=${EBOOK_INTERIM_STORAGE:-${HOME}/ff-epub}
	fi
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
						"${EBOOK_INTERIM_STORAGE}/${base}.azw3" \
						|| \
					{ echo "Failed to convert ${file}" 1>&2;
						return 2; }
				mv -i "${EBOOK_INTERIM_STORAGE}/${base}.azw3" \
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
 [ "${BASH_SOURCE[0]}" = "$0" ] && to_kindle "$@"
