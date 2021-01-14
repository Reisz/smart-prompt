#!/bin/bash
smart_prompt_colored() {
    printf '\001\e[%sm\002%s\e\001[0m\002' "$1" "$2"
}

smart_prompt_title() {
    case "$TERM" in
        xterm*|rxvt*) printf '\001\e]0;%s\a\002' "$1";;
    esac
}

smart_prompt_remote() {
    local _remote
    if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
        _remote=1
    else
        case $(ps -o comm= -p $PPID) in
            sshd|*/sshd) _remote=1;;
        esac
    fi

    if [ "$_remote" ]; then
        printf '%s' "$1"
    else
        printf '%s' "$2"
    fi
}

smart_prompt_hostname_color() {
    # default color is calculated from hash between 17 and 230 inclusive
    printf '%s' "$(($(echo "$HOSTNAME" | sum | grep -o "[1-9][0-9][0-9]*") % 213 + 17))"
}

smart_prompt_root_color() {
    if [[ $(whoami) == "root" ]]; then
        printf '%s' "$2"
    else
        printf '%s' "$1"
    fi
}

smart_prompt_swap() {
    if [ "$DISPLAY" ]; then
        printf '%s' "$1"
    else
        printf '%s' "$2"
    fi
}
