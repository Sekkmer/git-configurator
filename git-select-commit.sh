#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

command=('log')
pre_args=()
post_args=()
format='%C(auto)%h%d %s %C(green)(%an) %C(reset)%C(black bold)%cr'
max_count=''
do_graph=1

while [[ $# -gt 0 ]]; do
	KEY="$1"
	shift
	case "$KEY" in
	--walk-reflog | -g)
		command=('reflog')
		format='%C(auto)%h %C(bold magenta)%gd%C(auto)%d %gs %C(reset)| %C(dim green)(%an) %C(black)%C(bold)%cr'
		do_graph=0
		;;
	--walk-stash | -s)
		command=('stash' 'list')
		format='%C(auto)%h %gd %s %C(green)(%an) %C(reset)%C(black bold)%cr'
		do_graph=0
		;;
	--no-graph)
		do_graph=0
		;;
	--max-count | -n)
		if [[ $# -eq 0 ]]; then
			echo "Error: --max-count requires an argument" >&2
			exit 1
		fi
		max_count="$1"
		shift
		;;
	*)
		post_args+=("$KEY")
		;;
	esac
done

if [[ "$do_graph" -eq 1 ]]; then
	if [[ -z "$max_count" ]]; then
		max_count=1000
	fi
	pre_args+=("--graph")
	pre_args+=("--max-count=$max_count")
elif [[ -n "$max_count" ]]; then
	pre_args+=("--max-count=$max_count")
fi

git "${command[@]}" "${pre_args[@]}" --color=always --format="$format" "${post_args[@]}" |
	sk --ansi --no-sort --reverse --print-query --expect=ctrl-d \
		--preview 'echo {} | grep -m 1 -oE "[a-z0-9]+" | head -1 | xargs git show --color=always' |
	tail -1 |
	grep -m 1 -oE "[a-z0-9]+" |
	head -1
