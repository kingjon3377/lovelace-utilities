#!/bin/bash
# We use bash arrays for Wordpress blogs, etc.
if [ "${BASH_SOURCE}" = "$0" ];then
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        OPEN=open
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config" ]; then
        OPEN=xdg-open
        . "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config"
    else
        WGET="wget --progress=dot"
    fi
fi
WGET="wget --progress=dot"
backup_goodreads() {
	# Cookies extracted from Firefox by hand.
#	${WGET} -O "${HOME}/cabinet/web_services/goodreads.csv"
#		'https://www.goodreads.com/review_porter/goodreads_export.csv' \
#		--header='Cookie:cookieval' \
#	${OPEN} 'https://www.goodreads.com/review_porter/goodreads_export.csv'
	${OPEN} 'https://www.goodreads.com/review/import'
}
# Note that this doesn't (yet) support WP blogs outside wordpress.com
backup_wordpress() {
	# TODO: get cookies to entirely automate this
    for blog in "${WORDPRESS_BLOGS[@]}"; do
        #	${WGET} -O "${blog}.wordpress.$(date +%Y-%m_%d).xml" \
            ${OPEN} "https://${blog}.wordpress.com/wp-admin/export.php?type=export&download=true&content=all"
    done
}
backup_librarything() {
	#cookie=$(mktemp)
	# Cookies generated using LibraryThing.sh, in third_party, with the cleanup line at the end commented out.
	LT_CKSUM=${LT_CKSUM:-invalid}
	LT_UNUM=${LT_UNUM:-invalid}
	LT_UID=${LT_UID:-invalid}
	${WGET} --no-check-certificate -O "${LT_TARGET:-${HOME}/librarything.csv}" https://www.librarything.com/export-csv \
		--header="Cookie: cookie_userchecksum=${LT_CKSUM};cookie_usernum=${LT_UNUM};cookie_userid=${LT_UID}"
}
backup_delicious() {
#	xdg-open 'http://export.delicious.com/settings/bookmarks/export'
	${OPEN} 'https://delicious.com/settings/manage'
	# If that doesn't work, use <https://delicious.com/settings/manage>
	# instead, since it seems to require that as a referrer.
}
backup_diigo() {
	${OPEN} 'https://www.diigo.com/tools/export'
}
backup_facebook() {
	FB_DYI_KEY=${FB_DYI_KEY:-invalid}
	${OPEN} "https://www.facebook.com/dyi?x=${FB_DYI_KEY}"
	${OPEN} 'https://apps.facebook.com/give_me_my_data/'
}
backup_gmail() {
	offlineimap
}
backup_tracker() {
	tmpfile=$(mktemp)
	curl -H "X-TrackerToken: ${TRACKER_TOKEN:-invalid}" -X GET \
			https://www.pivotaltracker.com/services/v5/projects | \
			jq --unbuffered '.' |
			grep '"id"' | sed 's/^[   ]*"id": \([0-9]*\),$/\1/' | \
			cat - "${PIVOTAL_PROJECTS:-${HOME}/tracker_projects_list}" | sort -u | \
			tee "${tmpfile}" | while read project;do
		${OPEN} "https://www.pivotaltracker.com/projects/${project}/export"
		sleep 1
	done
	mv "${tmpfile}" "${PIVOTAL_PROJECTS:-${HOME}/tracker_projects_list}"
}
backup_simplenote() {
	${OPEN} 'http://simplenote-export.appspot.com/'
}
backup_web_services() {
	backup_goodreads && backup_librarything && backup_delicious && \
		backup_diigo && backup_facebook && backup_tracker && \
		backup_simplenote && backup_wordpress && backup_gmail
}
# Testing $_ (saved at the top of the script) against $0 isn't as reliable as
# $BASH_SOURCE, but is portable to other sh implementations
if [ "${BASH_SOURCE}" = "$0" ]; then
	backup_web_services "$@"
fi
