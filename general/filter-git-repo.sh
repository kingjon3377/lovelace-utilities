#!/bin/bash

# Use git-filter-repo to create (or update) a mirror of a subset of one Git repo in another repo.

# FIXME: To satisfy my use case, I need a way of including filename
# transformations other than ".txt -> .md", and (if not included in that) a way
# to strip non-minimal prefixes from paths that include them.

usage() {
    echo "Usage: filter-git-repo.sh --target TARGET_REPO_DIR [--markdown] INCLUDED_FILE [[--markdown] INCLUDED_FILE ...]" 1>&2
}

included_files=( )
markdown_files=( )
while test $# -gt 0;do
    if test "$1" = "--target" && test $# -gt 1; then
        if test -n "${target_dir}";then
            echo "Multiple target dirs are not supported." 1>&2
            usage
            exit 1
        else
            target_dir="${2}"
            shift;shift
            continue
        fi
    elif test "$1" = "--help";then
        usage
        exit 0
    elif test "$1" = "--markdown" && test $# -gt 1; then
        included_files+=( "$2" )
        markdown_files+=( "$2" )
        shift;shift
    else
        included_files+=( "$1" )
        shift
    fi
done

if test -z "${target_dir}"; then
    echo "Target dir is required" 1>&2
    usage
    exit 3
fi

if test "${#included_files[@]}" -eq 0; then
    echo "At least one file to include is required." 1>&2
    usage
    exit 2
fi

# This function is adapted from https://stackoverflow.com/a/12368678
# by "l0b0" (Victor Engmark), used under CC-BY-SA 3.0
common_prefix_pairwise() {
    if test $# -ne 2; then
        return 2
    fi

    # Remove repeated slashes
    for param in "$@";do
        param="$(printf %s. "$1" | tr -s '/')"
        set -- "$@" "${param%.}"
        shift
    done

    common_path="$1"
    shift

    for param in "$@";do
        while case "${param%/}/" in "${common_path%/}/"*) false ;; esac; do
            new_common_path="${common_path%/*}"
            if test "${new_common_path}" = "${common_path}"; then
                return 1 # Dead end
            fi
            common_path="${new_common_path}"
        done
    done
    printf %s "${common_path}"
}

common_prefix() {
    if test $# -eq 0; then
        return 1
    elif test $# -lt 2;then
        dirname "$1"
    else
        common_base="${1%/*}"
        if test "${common_base}" = "${1}";then
            common_base="."
        fi
        shift
        while test $# -gt 0;do
            new_common_base="$(common_prefix_pairwise "${common_base}/dummy.file" "${1}")"
            if test $? -ne 0; then
                return 2
            else
                common_base="${new_common_base}"
                shift
            fi
        done
        printf %s "${common_base}"
    fi
}

filter_repo_command=( git filter-repo )
prefix="$(common_prefix "${included_files[@]}")"
for arg in "${included_files[@]}";do
    filter_repo_command+=( --path "${arg}" )
    if test "${#markdown_files[@]}" -gt 0 && test "${arg}" = "${markdown_files[0]}";then
        dest_path="${markdown_files[0]}"
        dest_path="${dest_path#"${prefix}"}"
        dest_path="${dest_path#/}"
        if test "${dest_path%.txt}" != "${dest_path}";then
            dest_path="${dest_path%.txt}.md"
        fi
        if test "${arg}" != "${dest_path}"; then
            filter_repo_command+=( --path-rename "${arg}:${dest_path}" )
        fi
        markdown_files=( "${markdown_files[@]:1}" )
    else
        dest_path="${arg}"
        dest_path="${dest_path#"${prefix}"}"
        dest_path="${dest_path#/}"
        if test "${arg}" != "${dest_path}"; then
            filter_repo_command+=( --path-rename "${arg}:${dest_path}" )
        fi
    fi
done

filter_repo_command+=( --target "${target_dir}" )
echo "${filter_repo_command[@]}"
