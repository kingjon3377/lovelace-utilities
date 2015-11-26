#!/bin/sh
called_path=$_
whymask() {
    find /usr/portage/profiles/ -name '*.mask' -exec \
        awk -vRS= "/${*/\//.}/ {
                print \" \" FILENAME \":\", \"\n\" \"\n\" \$0 \"\n\"
        }" {} + | less
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${called_path}" = "$0" ]; then
#if [ "${BASH_SOURCE}" = "$0" ]; then
        whymask "$@"
fi
