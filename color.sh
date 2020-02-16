#!/bin/bash

smart_prompt_colored() {
    printf '\001\033[%sm\002%s\001\033[m\022' "$1" "$2"
}

smart_prompt_hostname_color() {
    # default color is calculated from hash between 17 and 230 inclusive
    printf '%s' "$(($(hostname | sum | grep -o "[1-9][0-9][0-9]*") % 213 + 17))"
}

smart_prompt_root_color() {
    if [[ $(whoami) == "root" ]]; then
        printf '%s' "$2"
    else
        printf '%s' "$1"
    fi
}
