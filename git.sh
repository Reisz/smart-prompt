#!/bin/bash
smart_prompt_git_update() {
    local _basedir _last_update _current_update
    _basedir=$(git rev-parse --show-toplevel)

    # store last update in .git/.update_timer
    if [ ! -f "$_basedir/.git/.smart_prompt_update_timer" ]; then
        _last_update=0
    else
        _last_update=$(cat "$_basedir/.git/.smart_prompt_update_timer")
    fi

    _current_update=$(date +%s)
    if [ $((_current_update - _last_update)) -gt "$1" ]; then
        touch "$_basedir/.git/.smart_prompt_updating"
        {
            git remote update
            rm "$_basedir/.git/.smart_prompt_updating"
        } >/dev/null 2>&1 &
        echo "$_current_update" > "$_basedir/.git/.smart_prompt_update_timer"
    fi


    if [ -f "$_basedir/.git/.smart_prompt_updating" ]; then
        smart_prompt_swap ' ↺' ' ↕'
    fi
}

smart_prompt_git() {
    if git status -s >/dev/null 2>&1; then
        # Manage timeout to update remotes, prints a symbol when updating
        smart_prompt_git_update "$1"

        # Main remotes
        local _push _pull
        if git show-branch "@{u}" >/dev/null 2>&1; then
            _push=$(git rev-list --count '@{push}..@')
            _pull=$(git rev-list --count '@..@{u}')

            if [ $((_push + _pull)) -gt 0 ]; then
                printf ' |'

                if [ "$_push" -gt 0 ]; then
                    smart_prompt_colored '38;5;220;1' " ▲$_push"
                fi

                if [ "$_pull" -gt 0 ]; then
                    smart_prompt_colored '38;5;220;1' " ▼$_pull"
                fi
            fi
        fi


        # Other remotes
        local _origin _branch
        _branch="$(git branch | grep "^\\*" | cut -c 3-)"
        if _origin=$(git rev-parse '@{u}' 2>/dev/null); then
            for _remote in $(git remote); do
                if [ "$(git rev-parse "refs/remotes/$_remote/$_branch")" != "$_origin" ]; then
                    _pull=$(git rev-list --count "@..refs/remotes/$_remote/$_branch")

                    if [ "$_pull" -gt 0 ]; then
                        printf ' | '
                        smart_prompt_colored '38;5;222;1' "$_remote ▼$_pull"
                    fi
                fi
            done
        fi

        printf ') '
    fi
}
