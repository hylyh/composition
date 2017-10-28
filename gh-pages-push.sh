#!/bin/sh

set -e

pub build
git add -f build/web
git commit -m "Deploying to gh-pages"
git push origin `git subtree split --prefix build/web master`:gh-pages --force

git reset HEAD~1