#!/bin/sh
python2 -c 'import sys, urllib; print urllib.unquote(sys.argv[1])' "$1"
