#!/bin/bash

set -euo pipefail

git select-commit | xargs printf "%s^1" | xargs git rebase -i
