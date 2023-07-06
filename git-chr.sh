#!/bin/bash

set -euo pipefail

git fetch --prune --no-tags --no-recurse-submodules --quiet

remote_branches="$(git for-each-ref --format='%(refname:short)' refs/remotes/origin | grep -vE 'origin$')"
local_branches="$(git for-each-ref --format='%(refname:short)' refs/heads)"
only_remote_banches="$(echo "$remote_branches" | grep -vE "$local_branches")"
branch="$(sk --ansi --no-sort --reverse --print-query --expect=ctrl-d <<<"$only_remote_banches" | tr -d '[:space:]')"

git checkout "$branch" "${@}"
