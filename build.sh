#!/bin/bash
gitbook init
gitbook build --output=../talkbox_gh-pages
cd ../talkbox_gh-pages
git init
git add .
git commit -a -m "update 20150130"
git remote add origin git@github.com:forthxu/talkbox.git
git push --force origin master:gh-pages
cd -