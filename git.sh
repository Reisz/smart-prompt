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
    if git show -s > /dev/null 2>&1; then
        printf '('
        smart_prompt_colored '38;5;160;1' 'Git'

        # Manage timeout to update remotes, prints a symbol when updating
        smart_prompt_git_update "$1"


        # Determine current branch / HEAD status
        local _branch _branch_col
        _branch=$(git branch | grep "^\\*" | colrm 1 2)
        _branch_col=165  # special case color
        if [ "$_branch" = "master" ]; then
            _branch_col=26  # master branch color
        elif [[ "$_branch" = "(no branch, rebasing"* ]]; then
            _branch="<rebasing>"
        elif [[ "$_branch" = "(HEAD detached"* ]]; then
            _branch="<detached>"
        else
            _branch_col=214  # regular branch color
        fi

        if [ "$_branch" ]; then
            smart_prompt_colored "38;5;$_branch_col;1" " $_branch"
        fi


        # Current commit
        local _commit
        _commit=$(git show --format=%h -q 2>/dev/null | head -1)
        if [[ -n $_commit ]]; then
            printf '@'
            smart_prompt_colored '38;5;242;1' "$_commit"
        fi


        # Uncomitted files
        local _status _staged _unstaged _untracked
        _status=$(git status --porcelain)
        _staged=$(echo "$_status" | grep -c "^. ")
        _unstaged=$(echo "$_status" | grep -c "^[^?][^ ]")
        _untracked=$(echo "$_status" | grep -c "^??")
        # print
        if [ "$_staged" -gt 0 ]; then
            smart_prompt_colored '38;5;34;1' " ↔$_staged"
        fi
        if [ "$_unstaged" -gt 0 ]; then
            smart_prompt_colored '38;5;220;1' " ○$_unstaged"
        fi
        if [ "$_untracked" -gt 0 ]; then
            smart_prompt_colored '38;5;196;1' " ?$_untracked"
        fi


        # Stash
        local _stash
        _stash=$(git stash list | wc -l)
        if [ "$_stash" -gt 0 ]; then
            printf ' | '
            smart_prompt_colored '38;5;63;1' "≡ $_stash"
        fi


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
        local _origin
        _origin=$(git rev-parse '@{u}' 2>/dev/null)
        for _remote in $(git remote); do
            if [ "$(git rev-parse "refs/remotes/$_remote/$_branch")" != "$_origin" ]; then
                _pull=$(git rev-list --count "@..refs/remotes/$_remote/$_branch")

                if [ "$_pull" -gt 0 ]; then
                    printf ' | '
                    smart_prompt_colored '38;5;222;1' "$_remote ▼$_pull"
                fi
            fi
        done

        printf ') '
    fi
}
