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
