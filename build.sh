#!/bin/bash
# git submodule init
# git submodule update #skynetwiki/FAQ.md 格式有问题
rm -rf ../talkbox_gh-pages

gitbook init
gitbook build --output=../talkbox_gh-pages

DATA_SECOND=`date +%Y-%m-%d-%H-%M-%S`
cd ../talkbox_gh-pages
rm -rf ./skynetwiki/.git
rm -rf ./build.sh
git init
git add .
git commit -a -m "update ${DATA_SECOND}"
git remote add origin git@github.com:forthxu/talkbox.git
git push --force origin master:gh-pages
cd -