#!/bin/bash

set -euo pipefail

script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
source "$script_dir/include.sh"

args=()
if should_use_log_graph "$@"; then
	args+=("--graph")
fi

git log "${args[@]}" --color=always --format="%C(auto)%h%d %C(reset)%s %C(dim green)(%an) %C(black)%C(bold)%cr"
