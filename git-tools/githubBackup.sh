#!/bin/bash
# do not forget first time `gh auth login`
# more information: https://stackoverflow.com/questions/19576742/how-to-clone-all-repos-at-once-from-github
nextUser() {
	echo
	echo "-----------"
	echo $1
	echo "-----------"
}
upsert() {
	echo
	echo "$1"
	if test -d "$1"; then
	(
		cd "$1"
		echo "update"
		git fetch origin
	)
	else
		echo "create"
		gh repo clone "$1" "$1" -- --bare
	fi
}

for user in user1 user2
do
	nextUser "$user"
	gh repo list $user --limit 4000 | while read -r repo _; do
		upsert "$repo"
	done
done
nextUser "user3"
upsert "user3/repo-of-user3"
