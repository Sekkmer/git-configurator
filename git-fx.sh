#!/bin/bash

set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$SCRIPT_DIR/include.sh"

check_staged_changes

commit=$(git select-commit) || exit 1
git commit --fixup "$commit"
