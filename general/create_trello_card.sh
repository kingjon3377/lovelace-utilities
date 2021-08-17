#!/bin/bash
# We use arrays, a bashism.
# shellcheck source=./lovelace-utilities-source-config.sh
. "${BASH_SOURCE[0]%/*}/lovelace-utilities-source-config.sh"

# Like submit_to_tracker.sh, but unlike most scripts in this collection, we
# don't define a reasonable default for the TRELLO_API_TOKEN. The
# create_trello_token() function will open a URL in your browser that will
# produce the token; set that to the variable. Throughout these functions,
# TRELLO_API_TOKEN defaults to invalidtoken. The documentation says that the
# "API key" is public, but since it can't be reset, I don't want to spread it
# *too* widely, so you'll have to get your own API key too; use that same function.
create_trello_token() {
	lovelace_utilities_source_config_bash
	if test "${TRELLO_API_KEY:-invalidkey}" = "invalidkey"; then
		${LOVELACE_OPEN:-xdg-open} "https://trello.com/app-key"
	else
		${LOVELACE_OPEN:-xdg-open} \
			"https://trello.com/1/authorize?key=${TRELLO_API_KEY}&name=Lovelace+Utilities&expiration=never&response_type=token&scope=read,write"
	fi
}
# Full "URL encoding" would be better, but to allow our methods to even work we
# have to replace all spaces with +s, and to avoid breakage we replace all
# ampersands with their URL-encoding equivalents.
minimal_sanitize() {
	tr ' ' '+' | sed 's/\&/%26/g'
}
# We use a differently-named function from echo for stderr to prevent programmer error.
errmsg() {
	echo "${@}" 1>&2
}
# Get the full 24-character ID of a Trello board given either its full ID (in
# which case this is an expensive no-op), the eight-character "short ID", or a
# string to match against the user's boards' names. Note that this matching is
# case-sensitive; case-insensitivity is a TODO item, but will require using a
# less-well-documented corner of jq.
# The ID or pattern is the only argument.
translate_trello_board() {
	lovelace_utilities_source_config_bash
	if test $# -ne 1; then
		errmsg "Usage: translate_trello_board board"
		return 1
	elif test -z "${1}"; then
		errmsg "Usage: translate_trello_board board"
		errmsg "Board must be nonempty"
		return 1
	fi
	local board_json secrets pattern=${1} id_matches short_matches string_matches
	secrets="key=${TRELLO_API_KEY:-invalidkey}&token=${TRELLO_API_TOKEN:-invalidtoken}"
	board_json="$(curl -s -X GET "https://api.trello.com/1/members/me/boards?${secrets}" 2>/dev/null)"
	retval=$?
	test ${retval} -eq 0 || return ${retval}
	matcher() {
		jq -r '.[] | {name,shortLink,id} | select('"${1}"') | .id'
	}
	read -r -a id_matches < <(echo "${board_json}" | matcher ".id == \"${pattern}\"")
	read -r -a short_matches < <(echo "${board_json}" | matcher ".shortLink == \"${pattern}\"")
	read -r -a string_matches < <(echo "${board_json}" | matcher ".name | contains(\"${pattern}\")")
	if test "${#id_matches[@]}" -eq 1; then
		echo "${id_matches[0]}"
	elif test "${#short_matches[@]}" -eq 1; then
		echo "${short_matches[0]}"
	elif test "${#string_matches[@]}" -eq 1; then
		echo "${string_matches[0]}"
	elif test "${#string_matches[@]}" -eq 0; then
		errmsg "No boards match '${pattern}'"
		return 1
	else
		errmsg "${#string_matches[@]} boards match '${pattern}'"
		return 2
	fi
}
# Similarly, this gets the 24-character ID of a list on a board given either
# its ID (in which case this is again an expensive no-op) or a string to match
# against the lists on the given board. This is again a case-sensitive match;
# case-insensitivity is a non-trivial TODO item.
# $1 is the board ID, which must be the full 24-character ID.
# $2 is the list ID or pattern
translate_trello_list() {
	lovelace_utilities_source_config_bash
	local board_json secrets pattern=${2} id_matches string_matches
	secrets="key=${TRELLO_API_KEY:-invalidkey}&token=${TRELLO_API_TOKEN:-invalidtoken}"
	board_json="$(curl -s -X GET "https://api.trello.com/1/boards/${1}/lists?${secrets}" 2>/dev/null)"
	retval=$?
	test ${retval} -eq 0 || return ${retval}
	matcher() {
		jq -r '.[] | {name,id} | select('"${1}"') | .id'
	}
	read -r -a id_matches < <(echo "${board_json}" | matcher ".id == \"${pattern}\"")
	read -r -a string_matches < <(echo "${board_json}" | matcher ".name | contains(\"${pattern}\")")
	if test "${#id_matches[@]}" -eq 1; then
		echo "${id_matches[0]}"
	elif test "${#string_matches[@]}" -eq 1; then
		echo "${string_matches[0]}"
	elif test "${#string_matches[@]}" -eq 0; then
		errmsg "No lists match '${pattern}'"
		return 1
	else
		errmsg "${#string_matches[@]} lists match '${pattern}'"
		return 2
	fi
}
# Add a card to a Trello board. Takes the following arguments:
# $1: the board (can be a pattern or short ID; we use translate_trello_board)
# $2: the list on that board (can be a pattern; we use translate_trello_list)
# $3: the card title: mandatory, must not be nonempty
# $4: the card description (optional)
# $5: The URL to associate with the card (optional)
submit_trello_story() {
	lovelace_utilities_source_config_bash
	if test $# -lt 3; then
		errmsg "Usage: submit_trello_story board list title [description] [url]"
		return 1
	fi
	local board=${1} list=${2}
	if test -z "${board}"; then
		errmsg "Usage: submit_trello_story board list title [description] [url]"
		errmsg "Board must be nonempty"
		return 1
	elif test -z "${list}"; then
		errmsg "Usage: submit_trello_story board list title [description] [url]"
		errmsg "List must be nonempty"
		return 1
	fi
	board="$(translate_trello_board "${board}")"
	retval=$?
	test ${retval} -eq 0 || return ${retval}
	list="$(translate_trello_list "${board}" "${list}")"
	retval=$?
	test ${retval} -eq 0 || return ${retval}
	local story_title story_desc=${4} story_url=${5}
	story_title="$(echo "${3}" | minimal_sanitize)"
	if test "${story_title:-null}" = "null"; then
		errmsg 'Story title was "null"!'
		return 2
	fi
	data="idList=${list}&token=${TRELLO_API_TOKEN:-invalidtoken}&key=${TRELLO_API_KEY:-invalidkey}&name=${story_title}"
	test -n "${story_desc}" && data="${data}&desc=$(echo "${story_desc}" | minimal_sanitize)"
	test -n "${story_url}" && data="${data}&urlSource=$(echo "${story_url}" | minimal_sanitize)"
    id=$(curl -s -X POST --data "${data}" "https://api.trello.com/1/cards" 2>/dev/null | jq -e '.id')
    if test $? != 0 || test "${id}" = null; then
        echo "Adding card apparently failed"
        return 3
    else
        echo "Added card with ID #${id}"
    fi
}
