#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/include.sh"

ARGS=()
while [ $# -gt 0 ]; do
	arg="$1"
	shift
	case "$arg" in
	-u | --update)
		git add --update
		;;
	-A | --all)
		git add --all
		;;
	*)
		ARGS+=("$arg")
		;;
	esac
done

check_staged_changes

commit=$(git select-commit) || exit 1
git commit --fixup "$commit"

for arg in "${ARGS[@]}"; do
	case "$arg" in
	-r | --rebase)
		git rebase "${REBASE_ARGS[@]}" --autosquash -i "$(printf "%s^1" "$commit")"
		;;
	*)
		echo "Unknown option: $arg"
		exit 1
		;;
	esac
done
