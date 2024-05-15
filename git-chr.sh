#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

git fetch --prune --no-tags --quiet

local_branches="$(git for-each-ref --format='%(refname:short)' refs/heads)"
remote_branches="$(git for-each-ref --format='%(refname:short)' refs/remotes/origin | grep -vE 'origin$')"

if [ -n "${local_branches}" ]; then
	remote_branches="$(echo "${remote_branches}" | grep -vE "${local_branches}")"
fi

if [ -n "${CHR_IGNORE:-}" ]; then
	remote_branches="$(echo "${remote_branches}" | grep -vE "${CHR_IGNORE}")"
fi

branch="$(echo "${remote_branches}" | sk --ansi --no-sort --reverse --print-query --expect=ctrl-d | tail -1 | tr -d '[:space:]')"

if [ -z "${branch}" ]; then
	echo "No branch selected"
	exit 1
fi

git checkout "${CHECKOUT_ARGS[@]}" "${branch}" "$@"
