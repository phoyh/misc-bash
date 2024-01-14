#!/bin/bash

for d in */ ; do
	echo "Checking $d"
	cd "$d"; git fsck; cd ..
	echo
done
