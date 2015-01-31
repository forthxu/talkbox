#!/bin/bash
gitbook init
gitbook build --output=../talkbox_gh-pages
DATA_SECOND=`date +%Y-%m-%d-%H-%M-%S`
cd ../talkbox_gh-pages
git init
git add .
git commit -a -m "update ${DATA_SECOND}"
git remote add origin git@github.com:forthxu/talkbox.git
git push --force origin master:gh-pages
cd -