#!/bin/bash

# $1: folder the files of which are to be placed into YYYY/MM subfolders

# Example: bash putFileToYearMonthDir.sh /media/KINGSTON/Pix

for i in $1/*
do
	mod_year=$(stat -c %y $i|sed 's/-.*//')
	mod_month=$(stat -c %y $i|sed 's/[0-9]*-//'|sed 's/-.*//')
	if [ ! -d "$1/$mod_year" ]; then
		mkdir "$1/$mod_year"
		echo Created directory $mod_year
	fi
	if [ ! -d "$1/$mod_year/$mod_month" ]; then
		mkdir "$1/$mod_year/$mod_month"
		echo Created directory $mod_year/$mod_month
	fi
	echo $i -\> $1/$mod_year/$mod_month
	mv "$i" "$1/$mod_year/$mod_month"
done
