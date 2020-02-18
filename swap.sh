#!/bin/bash
smart_prompt_swap() {
    if [ "$DISPLAY" ]; then
        printf '%s' "$1"
    else
        printf '%s' "$2"
    fi
}
