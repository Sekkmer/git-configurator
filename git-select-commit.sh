#!/bin/bash

set -euo pipefail

git log --graph --color=always --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
	sk --ansi --no-sort --reverse --print-query --expect=ctrl-d \
		--preview 'echo {} | grep -m 1 -oE "[a-z0-9]+" | head -1 | xargs git show --color=always' |
	tail -1 |
	grep -m 1 -oE "[a-z0-9]+" |
	head -1
