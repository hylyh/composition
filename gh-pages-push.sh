#!/bin/sh

# License: MIT (c) 2017 jenn kaplan and j hayley
# Build and push just the build directory to the gh-pages branch
# gh-pages branch must already exist
# Warning: Force pushes to gh-pages every time,
#  you shouldn't plan on working in that branch if you use this

set -e

BUILD="pub build"
BUILDDIR="build/web"

$BUILD
git add -f $BUILDDIR
git commit -m "Deploying to gh-pages"
git push origin `git subtree split --prefix $BUILDDIR master`:gh-pages --force

# Roll back the commit we made for the deploy (no working changes will be lost)
git reset HEAD~1