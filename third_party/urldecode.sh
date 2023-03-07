#!/bin/sh
python3 -c 'import sys; from urllib.parse import unquote; print(unquote(sys.argv[1]))' "$1"
