#!/bin/bash

if [ -d $VORKSCRIPT_DIR/Tools/boot.img-ramdisk ]
  then
    echo Found boot.img-ramdisk
  else
    echo Did not find $VORKSCRIPT_DIR/Tools/boot.img-ramdisk folder!
    exit 0
fi

cd $VORKSCRIPT_DIR/Tools

./mkbootfs boot.img-ramdisk | gzip > ramdisk-boot

cp ramdisk-boot $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/ramdisk-boot

cd $VORKSCRIPT_DIR
