#!/bin/sh
gs -sPAPERSIZE=a4 -sDEVICE=pnmraw -r300 -dNOPAUSE -dBATCH -sOutputFile=- -q "$@" | ocrad
