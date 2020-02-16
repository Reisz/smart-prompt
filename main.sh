#!/bin/bash
_smart_prompt_dir=$(dirname "${BASH_SOURCE[0]}")

# shellcheck source=exit_status.sh
source "$_smart_prompt_dir/exit_status.sh"

PS1=''

# exit_status.sh
smart_prompt_enable_exit_status

PS1+='\n\$ '
