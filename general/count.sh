#!/bin/bash
# Print the number of regular files in the directory given as $1, followed by that argument.
find "${1}" -maxdepth 1 -type f -printf '1\n' | wc -l | tr '\n' ' '
echo "${1}"
