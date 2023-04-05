#!/bin/bash

set -euo pipefail

git add -u
GIT_EDITOR=true git rebase --continue
