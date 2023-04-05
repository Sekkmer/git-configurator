#!/bin/bash

set -euo pipefail

commit=$(git select-commit) || exit 1
printf "%s^1" "$commit" | xargs -o git rebase -i
