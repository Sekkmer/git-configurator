#!/bin/bash

set -euo pipefail

search_query="${1:-}"
matching_branches=$(git branch --list "*$search_query*")
branch_count=$(echo "$matching_branches" | wc -l)
branch_to_checkout=$(if [ "$branch_count" -eq 1 ]; then echo "$matching_branches"; else echo "$matching_branches" | sk | tr -d "[:space:]"; fi)

changes=$(git status --porcelain)

if [ -n "$changes" ]; then
	echo "You have uncommitted changes. Do you want to stash them? [y/N]"
	read -n 1 -r
	echo
	if [[ $REPLY =~ ^[Yy]$ ]]; then
		git add -A
		git stash
	else
		echo "Aborting"
		exit 1
	fi
fi

git checkout "$branch_to_checkout"

if echo "$branch_to_checkout" | grep -q "^feature/"; then
	git pull
else
	git pull --rebase
fi
