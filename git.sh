#!/bin/bash
smart_prompt_git_update() {
    local _gitdir _last_update _current_update
    _gitdir=$(git rev-parse --git-dir)

    # store last update in .git/.update_timer
    if [ ! -f "$_gitdir/.smart_prompt_update_timer" ]; then
        _last_update=0
    else
        _last_update=$(cat "$_gitdir/.smart_prompt_update_timer")
    fi

    _current_update=$(date +%s)
    if [ $((_current_update - _last_update)) -gt "$1" ]; then
        touch "$_gitdir/.smart_prompt_updating"
        {
            git remote update
            rm "$_gitdir/.smart_prompt_updating"
        } >/dev/null 2>&1 &
        echo "$_current_update" > "$_gitdir/.smart_prompt_update_timer"
    fi


    if [ -f "$_gitdir/.smart_prompt_updating" ]; then
        smart_prompt_swap ' ↺' ' ↕'
    fi
}

smart_prompt_git() {
    if git status -s >/dev/null 2>&1; then
        # Manage timeout to update remotes, prints a symbol when updating
        smart_prompt_git_update "$1"


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
