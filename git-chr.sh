#!/bin/bash

set -euo pipefail

git fetch --prune --no-tags --quiet

local_branches="$(git for-each-ref --format='%(refname:short)' refs/heads)"
remote_branches="$(git for-each-ref --format='%(refname:short)' refs/remotes/origin | grep -vE 'origin$')"

if [ -n "${local_branches}" ]; then
	remote_branches="$(echo "${remote_branches}" | grep -vE "${local_branches}")"
fi

branch="$(echo "${remote_branches}" | sk --ansi --no-sort --reverse --print-query --expect=ctrl-d | tail -1 | tr -d '[:space:]')"

if [ -z "${branch}" ]; then
	echo "No branch selected"
	exit 1
fi

git checkout "${branch}" "$@"
