#!/bin/bash
# We use arrays, a bashism, and so use the nonportable but more reliable method of detecting sourceing.
chroot_wrapper_usage() {
	echo "Usage: ${0#*/} [-d DIR] [CHROOT_ARGS]"
	echo "where DIR is an optional path to chroot to"
	echo "($CWD is assumed as a default) and CHROOT_ARGS"
	echo "are the arguments to pass to chroot (like the"
	echo "command to run in the chroot; by default it"
	echo "passes /bin/bash -l)"
}

chroot_wrapper() {
	CHROOT_DIR=
	CHROOT_SHELL=

	# dir to chroot to is either $1 or $CWD
	while getopts ":d::" Option
	do
		case $Option in
			"d" ) CHROOT_DIR="$OPTARG" ;;
			*   ) ;;
		esac
	done
	shift $((OPTIND - 1))

	CHROOT_DIR="${CHROOT_DIR:-.}"
	if [ $# -gt 0 ];then
		CHROOT_SHELL=("${0}" "$@")
	else
		CHROOT_SHELL=( "/bin/bash" "-l" )
	fi

	[ -d "$CHROOT_DIR" ] || { echo "Bad path"; exit 1; }
	mount --rbind /proc "$CHROOT_DIR"/proc
	mount --rbind /dev "$CHROOT_DIR"/dev
	mount --rbind /sys "$CHROOT_DIR"/sys
	mount --rbind /home "$CHROOT_DIR"/home
	if [ -d "$CHROOT_DIR"/usr/portage ] ; then
		PORTAGE_MOUNTED="true"
		mount --rbind /usr/portage "$CHROOT_DIR"/usr/portage
	fi
	if [ -d "$CHROOT_DIR"/usr/local/portage ] ; then
		LOCAL_PORTAGE_MOUNTED="true"
		mount --rbind /usr/local/portage "$CHROOT_DIR"/usr/local/portage
	fi
	if [ -d "$CHROOT_DIR"/var/lib/layman ] ; then
		OVERLAYS_MOUNTED="true"
		mount --rbind /var/lib/layman "$CHROOT_DIR"/var/lib/layman
	fi
	if [ -d "${CHROOT_DIR}"/usr/src/linux ] && \
			[ $(find "${CHROOT_DIR}/usr/src/linux" | wc -l) -eq 1 ];then
		LINUX_SRC_MOUNTED="true"
		mount --rbind /usr/src/linux "${CHROOT_DIR}/usr/src/linux"
	fi
	cp /etc/resolv.conf "$CHROOT_DIR"/etc/resolv.conf
	chroot "$CHROOT_DIR" "${CHROOT_SHELL[@]}"

	[ -n "${LOCAL_PORTAGE_MOUNTED}" ] && umount "${CHROOT_DIR}/usr/local/portage"
	[ -n "${PORTAGE_MOUNTED}" ] && umount "${CHROOT_DIR}/usr/portage"
	[ -n "${OVERLAYS_MOUNTED}" ] && umount "${CHROOT_DIR}/var/lib/layman"
	[ -n "${LINUX_SRC_MOUNTED}" ] && umount "${CHROOT_DIR}/usr/src/linux"
	umount "$CHROOT_DIR/home"
	umount "$CHROOT_DIR/sys"
	umount "$CHROOT_DIR/dev"
	umount "$CHROOT_DIR/proc"
}
if [ "${BASH_SOURCE}" = "$0" ]; then
        chroot_wrapper "$@"
fi
