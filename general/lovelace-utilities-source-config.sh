#!/bin/sh
lovelace_utilities_xdg_config() {
    ( IFS=:
        for p in "${XDG_CONFIG_DIRS:-/etc/xdg}"; do
            if test -d "${p}/lovelace-utilities"; then
                echo "${p}/lovelace-utilities"
                break
            fi
        done
    )
}
lovelace_utilities_source_config() {
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config" ]; then
        LOVELACE_OPEN=open
        . "${HOME}/Library/Application Support/lovelace-utilities/config"
        LOVELACE_CONFIG_SOURCED=true
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config" ]; then
        LOVELACE_OPEN=xdg-open
        . "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config"
        LOVELACE_CONFIG_SOURCED=true
    else
        TEMP_XDG_CONFIG=$(lovelace_utilities_xdg_config)
        if [ -n "${TEMP_XDG_CONFIG}" ] && [ -f "${TEMP_XDG_CONFIG}/config" ]; then
            LOVELACE_OPEN=xdg-open
            . "${TEMP_XDG_CONFIG}/config"
            LOVELACE_CONFIG_SOURCED=true
        else
            LOVELACE_CONFIG_SOURCED=false
        fi
    fi
}
lovelace_utilities_source_config_bash() {
    if [ -d "${HOME}/Library/Application Support/lovelace-utilities" ] && \
            [ -f "${HOME}/Library/Application Support/lovelace-utilities/config-bash" ]; then
        LOVELACE_OPEN=xdg-open
        . "${HOME}/Library/Application Support/lovelace-utilities/config-bash"
        LOVELACE_CONFIG_SOURCED=true
    elif [ -n "${XDG_CONFIG_HOME:-${HOME}/.config}" ] && [ -d "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities" ] && \
            [ -f "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash" ]; then
            LOVELACE_OPEN=xdg-open
        . "${XDG_CONFIG_HOME:-${HOME}/.config}/lovelace-utilities/config-bash"
        LOVELACE_CONFIG_SOURCED=true
    else
        TEMP_XDG_CONFIG=$(lovelace_utilities_xdg_config)
        if [ -n "${TEMP_XDG_CONFIG}" ] && [ -f "${TEMP_XDG_CONFIG}/config-bash" ]; then
            LOVELACE_OPEN=xdg-open
            . "${TEMP_XDG_CONFIG}/config-bash"
            LOVELACE_CONFIG_SOURCED=true
        else
            LOVELACE_CONFIG_SOURCED=false
        fi
    fi
}
