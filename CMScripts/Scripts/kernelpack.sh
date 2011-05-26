#!/bin/bash

if [ -d $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk ]
  then
    echo Found boot.img-ramdisk

    if [ -e $SCRIPT_DIR/CMScripts/Tools/zImage ]
    then
      echo Found zImage
    else
      echo Did not find $SCRIPT_DIR/CMScripts/Tools/zImage
      exit 0
    fi
  else
    echo Did not find $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk folder!
    exit 0
fi

cd $SCRIPT_DIR/CMScripts/Tools

./mkbootfs boot.img-ramdisk | gzip > ramdisk-boot

./mkbootimg --kernel zImage --ramdisk ramdisk-boot --cmdline "$cline" -o newBoot.img --base 0x10000000

cd $SCRIPT_DIR/CMScripts/
