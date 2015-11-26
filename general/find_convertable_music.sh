#!/bin/sh
called_path=$_
find_convertable_music() {
	find . -xdev -name sermons -prune -o -name spatial -prune -o -name .kde4 -prune -o -path ./sys/windows -prune -o -path ./fromdisks -prune \
		-o -path ./Projects -prune -o -path ./src -prune -o -path ./.wesnoth -prune -o \
		-type f \( -iname \*.mp3 -o -iname \*.flac -o -iname \*.wma -o -iname \*.wav \) -print 
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
	find_convertable_music | less
fi
