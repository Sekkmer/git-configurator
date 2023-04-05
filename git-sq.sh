#!/bin/bash

set -euo pipefail

commit=$(git select-commit) || exit 1
git commit --squash "$commit"
