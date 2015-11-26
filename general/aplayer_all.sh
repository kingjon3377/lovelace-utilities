#!/bin/sh
for a in "$@"
do
	if [ -d "${a}" ]; then
		OLD_PWD="${PWD}"
		cd "${a}"
		alsaplayer $(ls|shuf)
		cd "${OLD_PWD}"
	elif [ -f "${a}" ]; then
		alsaplayer "${a}"
	fi
done

