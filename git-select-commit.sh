#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

args=()
if should_use_log_graph "$@"; then
	args+=("--graph")
fi

git log "${args[@]}" --color=always --format="%C(auto)%h%d %s %C(green)(%an) %C(reset)%C(black bold)%cr" "$@" |
	sk --ansi --no-sort --reverse --print-query --expect=ctrl-d \
		--preview 'echo {} | grep -m 1 -oE "[a-z0-9]+" | head -1 | xargs git show --color=always' |
	tail -1 |
	grep -m 1 -oE "[a-z0-9]+" |
	head -1
