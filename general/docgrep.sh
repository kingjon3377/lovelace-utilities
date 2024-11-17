#!/bin/bash
options=( )
args=( )
for arg in "$@"; do
	if test "${double_dash:-n}" = y;then
		args+=( "${arg}" )
	else
		case "${arg}" in
			--) double_dash=y ;;
			-*) options+=( "${arg}" ) ;;
			*) args+=( "${arg}" ) ;;
		esac
	fi
done
for file in "${args[@]}"; do
	case "${file}" in
		*.doc) catdoc "$file" | grep -q "${options[@]}" && echo "$file" ;;
		*.docx) docx2text "$file" | grep -q "${options[@]}" && echo "$file" ;;
		*) grep -l "${options[@]}" -- "$file" ;;
	esac
done
