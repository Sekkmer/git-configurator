#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

git fetch --prune --no-tags --quiet

args=()
new_branch_arg=""
new_branch_name=""
worktree_path=""
all="false"
remote="origin"

while [[ $# -gt 0 ]]; do
	case "$1" in
	-w | --worktree)
		worktree_path="${2:-}"
		if [[ -z "$worktree_path" || "$worktree_path" == -* ]]; then
			if [[ -n "$new_branch_name" ]]; then
				worktree_path="$new_branch_name"
			else
				echo "Error: Missing path for $1"
				exit 1
			fi
			shift
		else
			shift 2
		fi
		;;
	-b | -B)
		new_branch_arg="$1"
		new_branch_name="${2:-}"
		if [[ -z "$new_branch_name" || "$new_branch_name" == -* ]]; then
			echo "Error: Missing branch name for $1"
			exit 1
		fi
		shift 2
		;;
	-a | --all)
		all="true"
		shift
		;;
	-r | --remote)
		remote="${2:-}"
		if [[ -z "$remote" || "$remote" == -* ]]; then
			echo "Error: Missing remote for $1"
			exit 1
		fi
		shift 2
		;;
	*)
		args+=("$1")
		shift
		;;
	esac
done

local_branches="$(git for-each-ref --format='%(refname:short)' refs/heads)"
remote_branches="$(git for-each-ref --format='%(refname:short)' "refs/remotes/${remote}" | grep -vE "^${remote}\$")"

if [[ -n "${local_branches}" && "$all" == "false" ]]; then
	remote_branches="$(echo "${remote_branches}" | grep -vE "${local_branches}" || true)"
fi

if [ -n "${CHR_IGNORE:-}" ]; then
	remote_branches="$(echo "${remote_branches}" | grep -vE "${CHR_IGNORE}" || true)"
fi

if [ -z "${remote_branches}" ]; then
	echo "No remote branches found"
	exit 1
fi

selected_branch="$(echo "${remote_branches}" | sk --ansi --no-sort --reverse --print-query --expect=ctrl-d | tail -1 | tr -d '[:space:]')"

if [ -z "${selected_branch}" ]; then
	echo "No branch selected"
	exit 1
fi

if [ -n "$new_branch_name" ]; then
	if [[ "$new_branch_name" != *"/"* ]]; then
		new_branch_name="feature/$new_branch_name"
	fi
	args+=("$new_branch_arg" "$new_branch_name")
fi

if [ -n "$worktree_path" ]; then
	if [[ ! "$worktree_path" = /* ]] && [ -n "${WORKTREE_BASE_PATH:-}" ]; then
		worktree_path="${WORKTREE_BASE_PATH}/$(basename "$(pwd)")/${worktree_path}"
	fi

	mkdir -p "$(dirname "$worktree_path")"
	git worktree add "$worktree_path" "$selected_branch" "${args[@]}"

	cd "$worktree_path"
else
	git checkout "${CHECKOUT_ARGS[@]}" "$selected_branch" "${args[@]}"
fi

if [[ " ${CHECKOUT_ARGS[*]} " =~ " --recurse-submodules " ]]; then
	git submodule update --init --recursive
fi
