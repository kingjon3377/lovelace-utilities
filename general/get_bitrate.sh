#!/bin/bash
for file in "$@";do
	if ! test -f "$file"; then
		if test -f tmp/"${file}";then
			file=tmp/"${file}"
		else
			echo "${file} not found" 1>&2
			continue
		fi
	fi
	main_base="${file##*/}"
	case "${main_base}" in
		*.lrz)
			uncompressed_name="${main_base%%.lrz}"
			decompress=( lrunzip -D -q )
			;;
		*.rz)
			uncompressed_name="${main_base%%.rz}"
			decompress=( runzip )
			;;
		*.lz)
			uncompressed_name="${main_base%%.lz}"
			decompress=( lzip -d )
			;;
		*.bz2)
			uncompressed_name="${main_base%%.bz2}"
			decompress=( bunzip2 )
			;;
		*.gz)
			uncompressed_name="${main_base%%.gz}"
			decompress=( gunzip )
			;;
		*.mp3|*.ogg|*.opus|*.m4a)
			uncompressed_name="${main_base}"
			decompress=( : )
			;;
		*)
			echo "Unknown file type ${file}" 1>&2
			continue
			;;
	esac
	if test -f "${main_base}" || test -f "${uncompressed_name}";then
		echo "${file}: already exists, compressed or not, in staging area" 1>&2
		continue
	elif ! cp -i "${file}" "${main_base}";then
		echo "Copying ${file} to staging area failed" 1>&2
		break
	fi
	compressed_size="$(du -h "${main_base}")"
	if ! "${decompress[@]}" "${main_base}";then
		echo "Uncompressing ${file} failed" 1>&2
		break
	fi
	uncompressed_size="$(du -h "${uncompressed_name}")"
	bitrate=$(mediainfo --Output='Audio;%BitRate/String%' "${uncompressed_name}")
	test -z "${bitrate}" && bitrate=$(mediainfo --Output='Audio;%SamplingRate/String%' "${uncompressed_name}")
	echo "${compressed_size} ${uncompressed_size} ${bitrate}"
	rm -i "${uncompressed_name}"
done
