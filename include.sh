#!/bin/bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

if [ -s "$script_dir/.env" ]; then
	source "$script_dir/.env"
fi

export REBASE_ARGS=("${REBASE_ARGS[@]:-}")
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

function should_use_log_graph() {
	local arg
	for arg in "$@"; do
		if [[ "$arg" == "--graph" ]]; then
			return 1
		fi
		if [[ "$arg" == "--no-graph" ]]; then
			return 0
		fi
	done
	if [ -n "${GIT_LOG_NO_GRAPH-}" ]; then
		return 0
	fi
	local commit_count
	commit_count=$(git rev-list --count HEAD)
	if [ "$commit_count" -gt "$GIT_LOG_GRAPH_TRESHOLD" ]; then
		return 0
	fi
	return 1
}
