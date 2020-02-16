#!/bin/bash
smart_prompt_exit_status() {
    printf '\001\033[s\033[1A\033[%sC\002' "$((COLUMNS - 1))"

    # Can't check status directly since we're not calling ourselves
    # shellcheck disable=SC2181
    if [[ $? == 0 ]]; then
        printf '\001\033[38;5;46;1m\002✔\001\033[0m\002'
    else
        printf '\001\033[38;5;196;1m\002✘\001\033[0m\002'
    fi
    printf '\001\033[u\002'
}

# Enable exit status display after first prompt
_smart_prompt_prompt_count=0
smart_prompt_prompt_command() {
    if [ $_smart_prompt_prompt_count == 0 ]; then
        _smart_prompt_prompt_count=1
    else
        local _old="$PS1"
        PS1='$(smart_prompt_exit_status)'
        PS1+="$_old"

        unset PROMPT_COMMAND
        unset _smart_prompt_prompt_count
    fi
}

smart_prompt_enable_exit_status() {
    PROMPT_COMMAND=smart_prompt_prompt_command
}