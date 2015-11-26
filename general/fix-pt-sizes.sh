#!/bin/sh
sed 's/"/"\n/g' "${1}" | grep '[0-9]pt"$' | sed -e 's/pt"//' | sed -e "s/^\\(-\\|\\)\\(.*\\)$/echo 's:&pt:'\$(printf \"%.0f\" \$(echo \\2 '*' .75 | bc -l)):g/" | sh
