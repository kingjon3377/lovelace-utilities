#!/bin/sh
for xx in "$@"
do
	(echo ".pl 11i" ; /bin/gunzip -c "$(man -w "$xx")") | 
	/usr/bin/gtbl | 
	/usr/bin/groff -Tlatin1 -mandoc | 
	/usr/bin/less -is
done
