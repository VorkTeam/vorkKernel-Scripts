#!/bin/bash

if [ -d $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk ]
  then
    echo Found boot.img-ramdisk
  else
    echo Did not find $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk folder!
    exit 0
fi

cd $SCRIPT_DIR/CMScripts/Tools

./mkbootfs boot.img-ramdisk | gzip > ramdisk-boot

cp ramdisk-boot $SCRIPT_DIR/CMScripts/Awesome.zip/tmp/vorkKernel/ramdisk-boot

cd $SCRIPT_DIR/CMScripts/
