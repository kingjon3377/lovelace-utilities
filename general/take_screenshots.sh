#!/bin/bash
# A helper function for taking stills from a video file.
# Usage: take_screenshots /path/to/video screenshot_prefix
# TODO: Test number of arguments.
take_screenshots () { 
    mplayer -vf screenshot="${2}_shot" "${1}" && rm -i "${1}"
}
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	take_screenshots "$@"
fi
