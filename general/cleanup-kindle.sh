#!/bin/bash
# A script to remove ebooks not in a "favorites" list from an e-ink Kindle, and
# check whether those that are in the list are up to date.
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"

lovelace_utilities_source_config_bash

# TODO: Convert everything to a function, so things won't "exit" when this is sourced and something goes wrong

debug_print() {
	if test "${debug:-off}" = on; then
		echo "${@}" 1>&2
	else
		true
	fi
}

# Where the Kindle is mounted.
KINDLE_DIR="${KINDLE_DIR:-/mnt/kindle}"

# TODO: Cache favorites list (rather than iterating through the *file* for every not-in-favorites-exactly AZW/SDR)
# Every file that *should* be on the Kindle, other than dictionaries, "My
# Clippings", and the Kindle User Guide, is expected to be listed in this file,
# minus the .azw3 or .sdr extension, and each entry in this file is expected to
# be the path to an EPUB (other formats not yet supported) that actually exists
# that was converted to that Kindle-format ebook. Ebooks where the canonical
# name (listed in this file) includes non-ASCII characters are supported; on
# the Kindle their filenames should be the lowered-to-ASCII equivalent (with
# accents dropped, etc.)
KINDLE_FAVORITES="${KINDLE_FAVORITES:-${HOME}/favorite_fanfics.txt}"

# An array of markers indicating that a line may contain an indication of the
# date/time the ebook was published or updated; these lines are compared betwee
# the EPUB and the AZW to see if the latter is up to date. The default set
# should cover all EPUBs produced by FanFicFare or downloaded from AO3.
if test "${#CLEANUP_KINDLE_DATE_MARKERS[@]}" -lt 1; then
	CLEANUP_KINDLE_DATE_MARKERS=( 'Published:' 'Updated:' 'Packaged:' 'Completed:' )
fi

ncx_whitelist=( )
# CLEANUP_KINDLE_WHITELIST_NCX is an optional array of patterns that, if present
# in an NCX in the EPUB, indicate an inability to find dates in the EPUB is not
# a problem worth warning about.
if test "${#CLEANUP_KINDLE_WHITELIST_NCX[@]}" -ge 1; then
	for arg in "${CLEANUP_KINDLE_WHITELIST_NCX[@]}"; do
		ncx_whitelist+=( -e "${arg}" )
	done
	debug_print "NCX whitelist is (" "${ncx_whitelist[@]}" ")"
fi

opf_whitelist=( )
# Similarly, CLEANUP_KINDLE_WHITELIST_OPF is an optional array of patterns that, if
# in an OPF in the EPUB, indicate an inability to find dates in the EPUB is not
# a problem worth warning about.
if test "${#CLEANUP_KINDLE_WHITELIST_OPF[@]}" -ge 1; then
	for arg in "${CLEANUP_KINDLE_WHITELIST_OPF[@]}"; do
		opf_whitelist+=( -e "${arg}" )
	done
	debug_print "OPF whitelist is (" "${opf_whitelist[@]}" ")"
fi

general_whitelist=( )
# Similarly, CLEANUP_KINDLE_WHITELIST is an optional array of patterns that, if
# matched anywhere in the EPUB, indicate an inability to find dates is not a
# problem worth warning about.
if test "${#CLEANUP_KINDLE_WHITELIST[@]}" -ge 1; then
	for arg in "${CLEANUP_KINDLE_WHITELIST[@]}"; do
		general_whitelist+=( -e "${arg}" )
	done
	debug_print "General whitelist is (" "${general_whitelist[@]}" ")"
fi

if ! test -d "${KINDLE_DIR}/documents"; then
	echo "Kindle not mounted at ${KINDLE_DIR}" 1>&2
	exit 1
fi

cd "${KINDLE_DIR}/documents" || exit $?
debug_print "About to start pass through files on Kindle"
for file in *;do
	debug_print -n "Handling ${file} ... "
	case "$file" in
	dictionaries*) debug_print "a dictionary"; continue ;;
	"My Clippings"*) debug_print "user clippings"; continue ;;
	Kindle?User*) debug_print "User Guide"; continue ;;
	*.azw3) base="${file%%.azw3}" ;;
	*.sdr) base="${file%%.sdr}" ;;
	*) echo "Unexpected file $file" 1>&2 ; continue ;;
	esac
	grep -q "/${base}$" "${KINDLE_FAVORITES}" && debug_print "in favorites" && continue
	# Catch case where book title and canonical filename include Unicode characters
	matched=false
	while read -r line; do
		inner_file="${line##*/}"
		norm="$(echo "${inner_file}" | iconv -f UTF-8 -t ASCII//TRANSLIT -)"
		test "${inner_file}" = "${norm}" && continue
		test "${base}" = "${norm}" && matched=true && break
	done < "${KINDLE_FAVORITES}"
	test "${matched}" = true && continue
	if test -d "$file" && # test if empty
			! find "$file" -mindepth 1 -maxdepth 1 | read -r ; then
		debug_print "Removing empty directory"
		rmdir "$file"
	elif test -d "$file";then
		debug_print "Removing non-empty directory"
		echo -n "${file}: " && rm -rI "$file"
	else
		debug_print "Removing ordinary file"
		rm -i "$file"
	fi
done
debug_print "Finished pass through files on Kindle"
#debug=on
debug_print "About to start going through favorites list"
strip_calibre_markup() {
#	sed -e 's@ class="[^"]*"@@g' -e 's@ aid="[^"]*"@@g' -e 's@<br/>@<br />@' -e 's@<b >@<b>@' -e 's@[ 	][ 	]*@ @g'
	sed -e 's@<[^>]*>@@g' -e 's@[ 	][ 	]*@ @g' -e 's@^ @@'
}
dates_lines() {
	local temp=( )
	for arg in "${CLEANUP_KINDLE_DATE_MARKERS[@]}";do
		temp+=( -e "${arg}" )
	done
	grep "${temp[@]}" | strip_calibre_markup | sort
}
tmpdir="$(mktemp -d)"
while read -r line;do
	debug_print "line is ${line}"
	file="${line##*/}"
	norm="$(echo "${file}" | iconv -f UTF-8 -t ASCII//TRANSLIT -)"
	debug_print "Considering ${file}"
	if ! test -f "${norm}.azw3"; then
		echo "$file missing from Kindle"
		# TODO: if $line exists, use ebook-convert to load it
		continue
	elif ! test -f "${line}"; then
		echo "${file} missing from filesystem (wrong directory?)"
		continue
	fi
	dates_in_epub=$(unzip -p "${line}" '*htm*' | dates_lines)
	if test -z "${dates_in_epub}"; then
		if test "${#ncx_whitelist[@]}" -gt 0 && unzip -p "${line}" '*ncx' | grep -a -q "${ncx_whitelist[@]}"; then
			debug_print "${file} matches an NCX whitelist pattern"
		elif test "${#opf_whitelist[@]}" -gt 0 && unzip -p "${line}" '*opf' | grep -a -q "${opf_whitelist[@]}"; then
			debug_print "${file} matches an OPF whitelist pattern"
		elif test "${#general_whitelist[@]}" -gt 0 && unzip -p "${line}" | grep -a -q "${general_whitelist[@]}"; then
			debug_print "${file} matches a general whitelist pattern"
		else 
			echo "Failed to detect dates in ${file}" 1>&2
		fi
		continue
	fi
	if ! mobitool -s -o "${tmpdir}" "${norm}.azw3" > /dev/null || ! test -d "${tmpdir}/${norm}_markup"; then
		echo "Failed to extract metadata from ${norm}.azw3" 1>&2
		continue
	fi
	dates_in_azw=$(find "${tmpdir}/${norm}_markup" -name \*htm\* -exec cat {} + | dates_lines)
	if test -z "${dates_in_azw}"; then
		echo "Failed to detect dates in ${norm}.azw3" 1>&2
	elif test "${dates_in_epub}" != "${dates_in_azw}"; then
		echo "${norm}.azw3 may not be up to date from ${file}"
		debug_print "EPUB dates:\n${dates_in_epub}\n\nAZW dates:\n${dates_in_azw}"
	else
		debug_print "${norm}.azw3 appears to be up to date with ${file}"
	fi
	test "${debug:-off}" = on || rm -r "${tmpdir}/${norm}_markup"
	debug_print "Finished with ${file}"
done < "${KINDLE_FAVORITES}"
rmdir "${tmpdir}"
