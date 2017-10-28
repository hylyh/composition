#!/bin/sh

set -e

pub build
git add build/web
git commit -m "Deploying to gh-pages"
git push origin `git subtree split --prefix build/web master`:gh-pages --force
