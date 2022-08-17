#!/bin/sh
# Test whether a (media) file contains a video channel.
ffprobe -hide_banner "${1}" 2>&1 | grep -q 'Video:'
