#!/bin/bash
# We use bash arrays for Wordpress blogs, etc.
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"
backup_goodreads() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	# Cookies extracted from Firefox by hand.
#	${WGET} -O "${HOME}/cabinet/web_services/goodreads.csv"
#		'https://www.goodreads.com/review_porter/goodreads_export.csv' \
#		--header='Cookie:cookieval' \
#	${LOVELACE_OPEN} 'https://www.goodreads.com/review_porter/goodreads_export.csv'
	${LOVELACE_OPEN} 'https://www.goodreads.com/review/import'
}
# Note that this doesn't (yet) support WP blogs outside wordpress.com
backup_wordpress() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
		WORDPRESS_BLOGS=(  )
	fi
	# TODO: get cookies to entirely automate this
	for blog in "${WORDPRESS_BLOGS[@]}"; do
		#	${WGET} -O "${blog}.wordpress.$(date +%Y-%m_%d).xml" \
		${LOVELACE_OPEN} "https://${blog}.wordpress.com/wp-admin/export.php?type=export&download=true&content=all"
	done
}
backup_librarything() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	#cookie=$(mktemp)
	# Cookies generated using
	# [LibraryThing.sh](https://github.com/l0b0/export/blob/master/LibraryThing.sh),
	# with the cleanup line at the end commented out.
	LT_CKSUM=${LT_CKSUM:-invalid}
	LT_UNUM=${LT_UNUM:-invalid}
	LT_UID=${LT_UID:-invalid}
	${WGET} --no-check-certificate -O "${LT_TARGET:-${HOME}/librarything.csv}" https://www.librarything.com/export-csv \
		--header="Cookie: cookie_userchecksum=${LT_CKSUM};cookie_usernum=${LT_UNUM};cookie_userid=${LT_UID}"
}
backup_delicious() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
#	xdg-open 'http://export.delicious.com/settings/bookmarks/export'
	${LOVELACE_OPEN} 'https://del.icio.us/export'
}
backup_diigo() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	${LOVELACE_OPEN} 'https://www.diigo.com/tools/export'
}
backup_facebook() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	FB_DYI_KEY=${FB_DYI_KEY:-invalid}
	${LOVELACE_OPEN} "https://www.facebook.com/dyi?x=${FB_DYI_KEY}"
}
backup_gmail() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	if test -x /usr/bin/trickle; then
		trickle -s -d 150 -u 150 mbsync -V gmail
	else
		mbsync -V gmail
	fi
}
backup_tracker() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	tmpfile=$(mktemp)
	curl -H "X-TrackerToken: ${TRACKER_TOKEN:-invalid}" -X GET \
			https://www.pivotaltracker.com/services/v5/projects | \
			jq --unbuffered -r '.[] | .id' |
			cat - "${PIVOTAL_PROJECTS:-${HOME}/tracker_projects_list}" | sort -u | \
			tee "${tmpfile}" | while read -r project;do
		${LOVELACE_OPEN} "https://www.pivotaltracker.com/projects/${project}/export"
		sleep 1
	done
	mv "${tmpfile}" "${PIVOTAL_PROJECTS:-${HOME}/tracker_projects_list}"
}
backup_simplenote() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
		SIMPLENOTE_USERNAME="invalid%40example.com"
	fi
	${LOVELACE_OPEN} "https://app.simplenote.com/export/download?key=${SIMPLENOTE_USERNAME:-invalid%40example.com}"
}
backup_mint() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	${LOVELACE_OPEN} 'https://mint.intuit.com/transactionDownload.event?queryNew=&offset=0&filterType=cash&comparableType=8'
}
backup_linkedin() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	${LOVELACE_OPEN} 'https://www.linkedin.com/psettings/member-data'
}
backup_google_contacts() {
	lovelace_utilities_source_config_bash
	if [ "${LOVELACE_CONFIG_SOURCED:-false}" = false ]; then
		WGET="${WGET:-wget --progress=dot}"
		LOVELACE_OPEN=${LOVELACE_OPEN:-xdg-open}
	fi
	${LOVELACE_OPEN} 'https://contacts.google.com/'
}
backup_web_services() {
	backup_goodreads && backup_librarything && backup_delicious && \
		backup_diigo && backup_facebook && backup_tracker && \
		backup_mint && backup_simplenote && backup_wordpress && \
		backup_linkedin && backup_google_contacts && backup_gmail
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${BASH_SOURCE[0]}" = "$0" ]; then
	backup_web_services "$@"
fi
