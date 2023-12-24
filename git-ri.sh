#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

split=false

case "${1-}" in
-e | --edit)
	export GIT_SEQUENCE_EDITOR="sed -i -e '1s/^\(p\|pick\) /edit /'"
	shift
	;;
-r | --reword)
	export GIT_SEQUENCE_EDITOR="sed -i -e '1s/^\(p\|pick\) /reword /'"
	shift
	;;
-d | --drop)
	export GIT_SEQUENCE_EDITOR="sed -i -e '1s/^\(p\|pick\) /drop /'"
	shift
	;;
-s | --split)
	split=true
	;&
-b | --break)
	export GIT_SEQUENCE_EDITOR="sed -i '1i\\break'"
	shift
	;;
*)
	# No-op
	;;
esac

commit=$(git select-commit --grep="^fixup\!\|^squash\!" --invert-grep) || exit 1
printf "%s^1" "$commit" | xargs -o git rebase "${REBASE_ARGS[@]}" -i "$@"

if $split; then
	git cherry-pick --no-commit "$commit"
	git reset
fi
