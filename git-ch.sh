#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

search_query="${1:-}"
matching_branches=$(git for-each-ref --format='%(refname:short)' refs/heads | grep -E "$search_query" || true)

case "$(echo "$matching_branches" | wc -l)" in
0) ;;
1)
	branch_to_checkout="$matching_branches"
	;;
*)
	branch_to_checkout=$(echo "$matching_branches" | sk --ansi --no-sort --reverse --print-query --expect=ctrl-d | tail -1)
	;;
esac

if [ -z "$branch_to_checkout" ]; then
	echo "No branch selected"
	exit 1
fi

if [ "$branch_to_checkout" = "$(git rev-parse --abbrev-ref HEAD)" ]; then
	echo "Already on branch $branch_to_checkout"
	exit 0
fi

changes=$(git status --porcelain)

pop_stash=false
checkout_args=()

if [ -n "$changes" ]; then
	echo "You have uncommitted changes. Select an option:"
	echo "[s] Stash them"
	echo "[c] Continue with the changes"
	echo "[f] Force checkout, discarding the changes"
	echo "[p] Automatically stash and pop the changes"
	echo "othewise Abort"
	read -n 1 -r
	echo
	case "$REPLY" in
	[Ss])
		git add -A
		git stash
		;;
	[Cc])
		# No-op
		;;
	[Ff])
		checkout_args+=(--force)
		;;
	[Pp])
		git add -A
		git stash
		pop_stash=true
		;;
	*)
		echo "Aborting"
		exit 1
		;;
	esac
fi

git checkout "${CHECKOUT_ARGS[@]}" "$branch_to_checkout" "${checkout_args[@]}"

if echo "$branch_to_checkout" | grep -q "^feature/"; then
	git pull
else
	git pull --rebase
fi

if $pop_stash; then
	git stash pop
fi
