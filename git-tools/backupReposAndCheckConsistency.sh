#!/bin/bash

r="GameServer"

echo "Removing prior backup..."
rm -r "../gitBackup/$r"

echo "Creating new backup..."
cp -r "$r" "../gitBackup/"

echo "Checking new backup..."
cd "../gitBackup/$r"
git fsck

cd ../../git
echo "...done"

