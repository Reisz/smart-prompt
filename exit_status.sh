#!/bin/bash
smart_prompt_exit_status() {
    # Can't check status directly since we're not calling ourselves
    # shellcheck disable=SC218
    local _status=$?

    printf '\n\001\033[%sC\002' "$COLUMNS"

    if [[ "$_status" == 0 ]]; then
        smart_prompt_colored '38;5;46;1' "$(smart_prompt_swap ✔ o)"
    else
        smart_prompt_colored '38;5;196;1' "$(smart_prompt_swap ✘ x)"
    fi

    printf '\001\033[%sD\002' "$COLUMNS"
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
