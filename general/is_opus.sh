#!/bin/sh
# Test whether the codec in the given media file is Opus.
midentify "$1" | grep -q ffopus
