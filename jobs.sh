#!/bin/bash
smart_prompt_jobs() {
    local _stopped _running

    _stopped=$(jobs -s | grep -c "^\\[[0-9][0-9]*\\][+-] *Stop")
    _running=$(jobs -r | wc -l)

    if [ $((_stopped + _running)) -gt 0 ]; then
        printf '('
        smart_prompt_colored '38;5;42;1' 'Jobs'

        if [ "$_running" -gt 0 ]; then
            smart_prompt_colored '38;5;30;1' " $(smart_prompt_swap ► »)$_running"
        fi
        if [ "$_stopped" -gt 0 ]; then
            smart_prompt_colored '38;5;24;1' " ■$_stopped"
        fi

        printf ') '
    fi
}
