#!/bin/bash
# This is designed to be sourced in bash.
if [ "${BASH_SOURCE}" = "$0" ]; then
        echo "Source this file, don\'t execute it."
	exit 1
fi
setup() {
	find ~/music/itunes ~/music/choirs ~/music/sorted -type d | while read a; do
		pushd "${a}" > /dev/null
	done
	until [ -e .bookmark ]; do
		popd > /dev/null
	done
	dirs
	ls
}

advance() {
	rm .bookmark;popd;touch .bookmark;ls
}

edit_tags() {
	for file in *ogg; do
		vorbiscomment -c "${file%%.ogg}".tag "${file}"
	done
	vim ./*tag
}

apply_tags() {
	for file in *.ogg;do
		vorbiscomment -c "${file%%.ogg}".tag "${file}" -w && \
			rm "${file%%.ogg}.tag"
	done
}
