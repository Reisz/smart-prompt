#!/bin/bash
smart_prompt_screen() {
    if command -v screen > /dev/null; then
        local _screen_ls _detached _attached

        _screen_ls=$(screen -ls)
        _detached=$(echo "$_screen_ls" | grep -c Detached)
        _attached=$(echo "$_screen_ls" | grep -c Attached)

        if [ $((_attached + _detached)) -gt 0 ] || [ $STY ]; then
            printf '('
            smart_prompt_colored '38;5;98;1' 'Screen'

            # In screen?
            if [ $STY ]; then
                smart_prompt_colored '38;5;111;1' ' ♦'

                # Dont count currently running screen
                _attached=$((_attached - 1))
            fi

            # Attached
            if [ "$_attached" -gt 0 ]; then
                smart_prompt_colored '38;5;171;1' " A$_attached"
            fi

            # Detached
            if [ "$_detached" -gt 0 ]; then
                smart_prompt_colored '38;5;141;1' " D$_detached"
            fi

            printf ') '
        fi
    fi
}
