#!/bin/bash

# $1: folder the files of which are to be renamed to parent folder name and their index within the folder

# Example: bash renameFileByParentNameAndIndex.sh ~/Music/ttm

parent=$(basename "$1")

index=0

for i in $1/*
do
	index=$((index+1))
	indexName=00$index
	indexName=$(echo ${indexName: -3})
	filename=$(basename "$i")
	suffix=$(echo $filename|sed 's/[^.]*//')
	echo $i -\> $1/${parent}_\(${indexName}\)$suffix
	mv "$i" "$1/${parent}_(${indexName})$suffix"
done
