#!/bin/bash
count=0
for file in "$@";do
	if ! test -f "${file}" && test -f "tmp/${file}";then
		file="tmp/${file}"
	fi
	grep -q "^${file}" all_movies.txt && continue
	count=$((count + 1))
	if test $(( count % 10)) -eq 0;then
		echo "${file}" 1>&2
	fi
	case "${file}" in
		*.lrz) base="${file%%.lrz}"; uncompress=( lrunzip -D -q ) ;;
		*.rz) base="${file%%.rz}"; uncompress=( runzip ) ;;
		*.lz) base="${file%%.lz}"; uncompress=( lzip -d ) ;;
		*.bz2) base="${file%%.bz2}"; uncompress=( bunzip2 ) ;;
		*.gz) base="${file%%.gz}"; uncompress=( gunzip ) ;;
		*) base="${file}";uncompress=( : ) ;;
	esac
	case "${base}" in
		*.mkv|*.webm|*.mp4|*.avi|*.flv|*.m4v|*.ogv|*.3gp) : ;;
		*) echo "${file} doesn't look like a video, skipping ..." 1>&2; continue ;;
	esac
	if test "${file}" != "${file##*/}";then
		if test -f "${file##*/}" || test -f "${base##*/}"; then
			echo "${file##*/} or ${base##*/} exists in staging area, skipping" 1>&2
			continue
		elif ! cp -i "${file}" .;then
			echo "Copying ${file} to staging area failed" 1>&2
			exit 1
		elif ! "${uncompress[@]}" "${file##*/}"; then
			echo "Uncompressing ${file##*/} failed" 1>&2
			exit 2
		fi
		base=${base##*/}
		if echo "${base}" | grep -q -- '-[-0-9a-zA-Z_]\{11\}\.[^.]*$';then
			extra=' !!!!'
			extra="${extra} $(du -h "${base}" | cut -f1)"
		else
			extra=''
		fi
		codec=$(mediainfo --Output='Video;%Format/Info%' "${base}")
		resolution=$(mediainfo --Output='Video;%Width%x%Height%' "${base}")
		echo "${file}: ${codec} ${resolution}${extra}" >> all_movies.txt
		rm "${base}"
	fi
done
