#!/bin/sh
pdfname="${1}"
if [ "${pdfname}" = "${pdfname%.pdf}" ]
then
	echo "${pdfname} is not a PDF ... exiting"
	exit 1
fi
base="${pdfname%.pdf}"
mkdir $$
cp "${pdfname}" $$
cd "$$" || exit 2
pdftohtml -p -nodrm -nomerge -noframes "${pdfname}"
BROWSER="${BROWSER:-links}"
${BROWSER} "${base}".html
yesno() {
	dialog --yesno "${1}" 0 0
}
yesno 'Discard that and use complex mode?'
if [ $? -eq 0 ]
then
	rm "${base}"*.html "${base}"*.jpg
	pdftohtml -p -c -nodrm -noframes "${pdfname}"
	${BROWSER} "${base}".html
	yesno 'Discard that and use OCR later instead?'
	if [ $? -eq 0 ]
	then
		cd ..
		rm -r $$
		echo "Move ${pdfname} to a directory to be OCRed later."
		exit 0
	else
		mkdir "${base}"
		mv "${base}"*.html "${base}"*.png "${base}"
	fi
else
	mkdir "${base}"
	mv "${base}"*.html "${base}"*.jpg "${base}"
fi
tar cf "${base}".tar "${base}"
z-recursive.sh .
yesno "$(du -sh ./*)"'\nKeep tarball instead of PDF?'
if [ $? -eq 0 ]
then
	rm -r "${base}" "${pdfname}"*
	mv "${base}".tar* ..
	cd ..
	rmdir $$
	rm "${pdfname}"
else
	cd ..
	rm -r $$
fi
