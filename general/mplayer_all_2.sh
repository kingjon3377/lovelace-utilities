#!/bin/sh
mplayer $(for a in "$@"
do
	if [ -d "${a}" ]
	then
		find "${a}" -type f -print
	elif [ -f "${a}" ]
	then
		echo "${a}"
	fi
done | shuf)
