#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd)"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

function set_git_alias() {
	local alias_name=$1
	local alias_value=$2

	local current_alias=$(git config --global --get-all alias.$alias_name)

	if [[ -z "$current_alias" ]]; then
		git config --global alias.$alias_name "$alias_value"
		echo -e "${GREEN}Added alias:${NC} $alias_name"
	elif [[ "$current_alias" != "$alias_value" ]]; then
		git config --global --unset-all alias.$alias_name
		git config --global alias.$alias_name "$alias_value"
		echo -e "${YELLOW}Updated alias:${NC} $alias_name"
	fi
}

for entry in "$SCRIPT_DIR"/*; do
	filename="$(basename "$entry")"

	if [[ ! "$filename" =~ ^git- ]]; then
		continue
	fi

	alias_name="${filename#git-}"

	if [ -f "$entry" ]; then
		if [ -x "$entry" ]; then
			alias_name="${alias_name%.*}"
			alias_value="!$entry"
		else
			line_count=$(wc -l <"$entry")
			if [ "$line_count" -eq 1 ]; then
				alias_value=$(head -n 1 "$entry")
			else
				echo -e "${RED}Warning:${NC} $entry is not executable and has more than one line"
				continue
			fi
		fi
	else
		echo -e "${RED}Warning:${NC} $entry is not a file"
		continue
	fi

	set_git_alias "$alias_name" "$alias_value"
done
