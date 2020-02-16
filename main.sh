#!/bin/bash
_smart_prompt_dir=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=color.sh
source "$_smart_prompt_dir/color.sh"
# shellcheck source=exit_status.sh
source "$_smart_prompt_dir/exit_status.sh"
# shellcheck source=jobs.sh
source "$_smart_prompt_dir/jobs.sh"

PS1=''

# Exit status
smart_prompt_enable_exit_status

# Host name
PS1+="[$(smart_prompt_colored "38;5;$(smart_prompt_hostname_color);1" '\u@\h')] "

# Jobs
PS1+='$(smart_prompt_jobs)'

# Working directory
PS1+="$(smart_prompt_colored "38;5;$(smart_prompt_root_color "75" "1");1" '\w') "

PS1+='\n\$ '
