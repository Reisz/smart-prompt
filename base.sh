#!/bin/bash
smart_prompt_colored_hostname() {
    local _prompt="${1:-\u@\h}"

    # default color is calculated from hash between 17 and 230 inclusive
    local _host_color=$(($(hostname | sum | grep -o "[1-9][0-9][0-9]*") % 213 + 17))

    printf '\001\033[38;5;%s;1m\002%s\001\033[0m\002' "$_host_color" "$_prompt"
}
