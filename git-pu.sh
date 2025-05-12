#!/bin/bash

set -euo pipefail

args=()
upstream='origin'

while [[ $# -gt 0 ]]; do
	case $1 in
	-u | --upstream)
		upstream="$2"
		shift 2
		;;
	*)
		args+=("$1")
		shift
		;;
	esac
done

git push --set-upstream "$upstream" "$(git symbolic-ref --short HEAD)" "${args[@]}"
