#!/bin/bash
whymask() {
    find /usr/portage/profiles/ -name '*.mask' -exec \
        awk -vRS= "/${*/\//.}/ {
                print \" \" FILENAME \":\", \"\\n\" \"\\n\" \$0 \"\\n\"
        }" {} + | less
}
# We use more reliable sourcing-detection because string replacement is a
# bashism.
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
        whymask "$@"
fi
