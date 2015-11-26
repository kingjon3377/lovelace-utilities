#!/bin/sh
pdbname="${1}"
if [ "${pdbname}" = "${pdbname%.pdb}" ]
then
	echo "${pdbname} is not a PDB ... exiting"
	exit 1
fi
base="${pdbname%.pdb}"
txt2pdbdoc -d "${base}".pdb "${base}".txt
less "${base}".txt
dialog --yesno 'Discard that and leave the PDB?' 0 0
if [ $? -eq 0 ]
then
	rm "${base}.txt"
	exit 0
else
	# FIXME: The original, which used basename to get the file name, and
	# copied the original to a temporary directory before running the
	# conversion, compressed the converted file and (its copy of) the
	# original before showing the sizes. We should do something similar.
	#z-recursive.sh .
	dialog --yesno "$(du -h "${base}.pdb" "${base}.txt")"'\nKeep TXT instead of PDB?' 0 0
	if [ $? -eq 0 ]
	then
		rm "${pdbname}"
	fi
fi
