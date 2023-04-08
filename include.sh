#!/bin/bash

set -euo pipefail

function check_staged_changes() {
	while git diff --cached --quiet --exit-code; do
		echo "No staged changes in the repository."
		read -p "Choose an option [u: git add -u | a: git add -A | r: recheck]: " choice
		case $choice in
		u)
			git add -u
			echo "Added updated files to staging area."
			;;
		a)
			git add -A
			echo "Added all files to staging area."
			;;
		r)
			echo "Rechecking for staged changes..."
			;;
		*)
			echo "Invalid option. Please choose 'u', 'a', or 'r'."
			;;
		esac
	done
}
