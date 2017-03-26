#!/bin/bash

echo -e "\033[0;32mDeploying updates to GitHub...\033[0m"

rm -rf public
git clone git@github.com:takady/takady.github.io.git public

# Build the project.
hugo

# Go To Public folder
cd public
# Add changes to git.
git add -A

# Commit changes.
msg="rebuilding site `date -u +'%Y-%m-%d %H:%M:%S UTC'`"
if [ $# -eq 1 ]
  then msg="$1"
fi
git commit -m "$msg"

# Push source and build repos.
git push origin master

# Come Back
cd ..
