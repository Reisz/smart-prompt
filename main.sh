#!/bin/bash
_smart_prompt_dir=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=exit_status.sh
source "$_smart_prompt_dir/exit_status.sh"
# shellcheck source=git.sh
source "$_smart_prompt_dir/git.sh"
# shellcheck source=jobs.sh
source "$_smart_prompt_dir/jobs.sh"
# shellcheck source=screen.sh
source "$_smart_prompt_dir/screen.sh"
# shellcheck source=util.sh
source "$_smart_prompt_dir/util.sh"

# Exit status
smart_prompt_enable_exit_status

PS1=''
# Title: [host]_~/current/directory
PS1+="$(smart_prompt_title "$(smart_prompt_remote '[\h] ')\w")"
# [user@host]_
PS1+="[$(smart_prompt_colored "38;5;$(smart_prompt_hostname_color);1" '\u@\h')] "
# (Jobs ►0 ■0)_
PS1+='$(smart_prompt_jobs)'
# (Screen ♦ A0 D0)_
PS1+='$(smart_prompt_screen)'
# ~/current/directory_
PS1+="$(smart_prompt_colored "38;5;$(smart_prompt_root_color "75" "1");1" '\w') "
# (Git branch@revision ↔0 ○0 ?0 | ≡ 0 | ▲0 ▼0 | remote ▼0)_
PS1+='$(smart_prompt_git 600)'
# Empty line for prompt
PS1+='\012\$ '
