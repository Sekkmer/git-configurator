#!/bin/bash

set -euo pipefail

search_query="${1:-}"
matching_branches=$(git branch --list "*$search_query*")
branch_count=$(echo "$matching_branches" | wc -l)
branch_to_checkout=$(if [ "$branch_count" -eq 1 ]; then echo "$matching_branches"; else echo "$matching_branches" | sk | tr -d "[:space:]"; fi)

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

git checkout "$branch_to_checkout" "${checkout_args[@]}"

if echo "$branch_to_checkout" | grep -q "^feature/"; then
	git pull
else
	git pull --rebase
fi

if $pop_stash; then
	git stash pop
fi
