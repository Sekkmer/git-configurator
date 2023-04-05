#!/bin/bash

set -euo pipefail

UPSTREAM=${1:-origin}
BRANCH_NAME=$(git symbolic-ref --short HEAD)

git push -u "$UPSTREAM" "$BRANCH_NAME" "$@"
