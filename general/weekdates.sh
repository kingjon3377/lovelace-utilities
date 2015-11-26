#!/bin/sh
y=2013

for d in $(seq 0 6)
do
	if [ "$(date -d "$y-1-1 + $d day" '+%u')" -eq 5 ]   # +%w: Mon == 1 also
	then
		break
	fi
done

for w in $(seq "$d" 7 "$(date -d "$y-12-31" '+%j')")
do
	date -d "$y-1-1 + $w day" '+%Y/%m/%d'
done
