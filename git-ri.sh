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

case "${1:-}" in
	e|edit|-e|--edit)
		export GIT_SEQUENCE_EDITOR="sed -i '1s/^/$pick /$edit /'"
	;;
	r|reword|-r|--reword)
		export GIT_SEQUENCE_EDITOR="sed -i '1s/^/$pick /$reword /'"
	;;
	d|drop|-d|--drop)
		export GIT_SEQUENCE_EDITOR="sed -i '1s/^/$pick /$drop /'"
	;;
	*)
		# No-op
	;;
esac

commit=$(git select-commit) || exit 1
printf "%s^1" "$commit" | xargs -o git rebase -i
