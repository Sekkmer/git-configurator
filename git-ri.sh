#!/bin/bash

set -euo pipefail

git select-commit | xargs git rebase --interactive
