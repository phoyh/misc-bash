#!/bin/bash

# $1: folder to be converted
# $2: separating string between date and time (or empty)

# Example: bash renameFileByDateTime.sh /media/KINGSTON/2012 _
# Example: bash renameFileByDateTime.sh /media/KINGSTON/2012

for i in $1/*
do
	mod_datetime=$(stat -c %y $i|sed 's/-//g'|sed "s/ /$2/"|sed 's/://g'|sed 's/\..*//')
	suffix=$(echo $i|sed 's/.*\.//g')
	mv "$i" "$1/$mod_datetime.$suffix"
	echo $i -\> $1/$mod_datetime.$suffix
done
