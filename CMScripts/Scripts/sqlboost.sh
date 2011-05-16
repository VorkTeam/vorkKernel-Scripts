#!/bin/bash

cd $SCRIPT_DIR/CM/external/sqlite

git add .
git reset --hard

cd $SCRIPT_DIR/CM

git fetch github
git checkout remotes/github/gingerbread

patch "/home/vork/CM/external/sqlite/dist/sqlite3.c" "/home/vork/CMScripts/Tools/nosync.txt"

cp ./vendor/lge/p990/p990-vendor.mk ./buildspec.mk
. build/envsetup.sh
lunch cyanogen_p990-eng

make out/target/product/p990/system/lib/libsqlite.so

cd $SCRIPT_DIR/CMScripts/
