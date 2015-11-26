#!/bin/sh
cd ~ || exit 1
find . -path ./.mozilla -prune -o -path ./.avfs -prune -o -path ./temp -prune -o \( -iname \*.pdf -o -iname \*.pdf.gz -o -iname \*.pdf.bz2 -o -iname \*.pdf.rz -o -iname \*.pdf.lrz \) -print | grep -v ocr_later | grep -v keep_as_PDF | less
