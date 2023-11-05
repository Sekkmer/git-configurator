#!/bin/bash

set -euo pipefail

git fetch --prune --no-tags --quiet

local_branches="$(git for-each-ref --format='%(refname:short)' refs/heads)"

git for-each-ref --format='%(refname:short)' refs/remotes/origin \
	| grep -vE 'origin$' \
	| grep -vE "$local_branches" \
	| sk --ansi --no-sort --reverse --print-query --expect=ctrl-d \
	| tail -1 \
	| tr -d '[:space:]' \
	| xargs -I {} git checkout "{}" "${@}"
