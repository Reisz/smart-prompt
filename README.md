# smart-prompt
Modular collection of bash prompt functionality

Supports the following features
- Hostname-based recoloring
- Root recoloring
- Count stopped & background jobs
- Display status of screens
- Display exit status of previous command

## Character set
Symbols used in the prompt should be part of [CP437](https://en.wikipedia.org/wiki/Code_page_437). The command `smart_prompt_swap` can be used to substitute them for more fitting Unicode symbols if the current terminal supports Unicode.
