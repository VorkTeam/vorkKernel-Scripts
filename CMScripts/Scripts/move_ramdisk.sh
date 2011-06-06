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

sed -i 's/mount ext3 \/dev\/block\/mmcblk0p8/mount ext4 \/dev\/block\/mmcblk0p8/' $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk/init.p990.rc
sed -i 's/mount ext3 \/dev\/block\/mmcblk0p1/mount ext4 \/dev\/block\/mmcblk0p8/' $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk/init.p990.rc
./mkbootfs boot.img-ramdisk | gzip > ramdisk-boot
cp ramdisk-boot $SCRIPT_DIR/CMScripts/Awesome.zip/tmp/vorkKernel/files/ramdisk-boot-EXT4
sed -i 's/mount ext4 \/dev\/block\/mmcblk0p8/mount ext3 \/dev\/block\/mmcblk0p8/' $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk/init.p990.rc
sed -i 's/mount ext4 \/dev\/block\/mmcblk0p1/mount ext3 \/dev\/block\/mmcblk0p8/' $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk/init.p990.rc

cd $SCRIPT_DIR/CMScripts/
