#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if [ -s "$script_dir/.env" ]; then
	source "$script_dir/.env"
fi

if [ -n "${REBASE_ARGS:-}" ]; then
	export REBASE_ARGS
else
	export REBASE_ARGS=()
fi

if [ -n "${CHECKOUT_ARGS:-}" ]; then
	export CHECKOUT_ARGS
else
	export CHECKOUT_ARGS=()
fi

if [ -n "${WORKTREE_BASE_PATH:-}" ]; then
	export WORKTREE_BASE_PATH
else
	export WORKTREE_BASE_PATH="$HOME/git/worktrees"
fi

export GIT_LOG_GRAPH_TRESHOLD="${GIT_LOG_GRAPH_TRESHOLD:-10000}"
export GIT_LOG_NO_GRAPH="${GIT_LOG_NO_GRAPH:-}"

function check_staged_changes() {
	while git diff --cached --quiet --exit-code; do
		echo "No staged changes in the repository."
		read -p "Choose an option [u: git add -u | a: git add -A | r: recheck]: " choice
		case $choice in
		u)
			git add -u
			echo "Added updated files to staging area."
			;;
		a)
			git add -A
			echo "Added all files to staging area."
			;;
		r)
			echo "Rechecking for staged changes..."
			;;
		*)
			echo "Invalid option. Please choose 'u', 'a', or 'r'."
			;;
		esac
	done
}

function load_config() {
	local result=''

	result="$(git config --get reconfigure.rebase-args || true)"
	for arg in $result; do
		REBASE_ARGS+=("$arg")
	done
	export REBASE_ARGS

	result="$(git config --get reconfigure.checkout-args || true)"
	for arg in $result; do
		CHECKOUT_ARGS+=("$arg")
	done
	export CHECKOUT_ARGS

	result="$(git config --get reconfigure.worktree-base-path || true)"
	if [ -n "$result" ]; then
		WORKTREE_BASE_PATH="$result"
	fi
	export WORKTREE_BASE_PATH
}

load_config
