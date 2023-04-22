#!/bin/bash

set -euo pipefail

abbreviateCommands=$(git config --get rebase.abbreviateCommands || true)

if [ "$abbreviateCommands" = "true" ]; then
	pick="p"
	edit="e"
	reword="r"
	drop="d"
else
	pick="pick"
	edit="edit"
	reword="reword"
	drop="drop"
fi

function auto_rebase() {
	earliest_target_hash=""
	earliest_target_timestamp=""

	for line in git log --pretty=oneline --abbrev-commit --grep="^fixup\!\|^squash\!" --all; do
		commit_hash=$(echo "$line" | awk '{print $1}')
		commit_msg=$(echo "$line" | awk '{$1=""; print $0}')

		target_hash=$(echo "${commit_msg#*!}" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
		target_hash_full=$(git rev-parse --verify "$target_hash")

		if [ -z "$earliest_target_hash" ]; then
			earliest_target_hash="$target_hash_full"
			earliest_target_timestamp=$(git show -s --format=%ct "$target_hash_full")
		else
			current_target_timestamp=$(git show -s --format=%ct "$target_hash_full")
			if [ "$current_target_timestamp" -lt "$earliest_target_timestamp" ]; then
				earliest_target_hash="$target_hash_full"
				earliest_target_timestamp="$current_target_timestamp"
			fi
		fi
	done

	echo "$earliest_target_hash"
}

case "${1-}" in
e | edit | -e | --edit)
	export GIT_SEQUENCE_EDITOR="sed -i -e '1s/^/$pick /$edit /'"
	;;
r | reword | -r | --reword)
	export GIT_SEQUENCE_EDITOR="sed -i -e '1s/^/$pick /$reword /'"
	;;
d | drop | -d | --drop)
	export GIT_SEQUENCE_EDITOR="sed -i -e '1s/^/$pick /$drop /'"
	;;
a | auto | -a | --auto)
	printf "%s^1" "$(auto_rebase)" | xargs -o git rebase -i
	exit 0
	;;
*)
	# No-op
	;;
esac

commit=$(git select-commit --grep="^fixup\!\|^squash\!" --invert-grep) || exit 1
printf "%s^1" "$commit" | xargs -o git rebase -i
