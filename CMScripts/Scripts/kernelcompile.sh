#!/bin/bash

cd $SOURCE_DIR

echo "Building ..."
make ARCH=arm CROSS_COMPILE=$ARM_EABI vorkKernel_defconfig

NOW=$(date +"%d%m%y")
if [ "$release" == "release" ]; then
signed_file=vorkKernel-LGP990-'$NOW'.zip
else
signed_file=vorkKernel-LGP990.zip
fi

export localVersion=`cat .config | fgrep CONFIG_LOCALVERSION= | cut -f 2 -d = | sed s/\"//g`
export linuxVersion=`cat .config | fgrep "Linux kernel version: "| cut -c25-34 | sed s/\"//g`
export VERSION=$linuxVersion$localVersion

rm $SCRIPT_DIR/CMScripts/Update.zip/kernel/boot.img
rm -rf $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/*

echo Building the kernel
ARCH=arm CROSS_COMPILE=$ARM_EABI make -j`grep 'processor' /proc/cpuinfo | wc -l`
make ARCH=arm CROSS_COMPILE=$ARM_EABI INSTALL_MOD_PATH=$SCRIPT_DIR/CMScripts/Update.zip/system modules_install

cp arch/arm/boot/zImage $SCRIPT_DIR/CMScripts/Tools

for module in `find $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/kernel/ -name *.ko`
do
    cp $module $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/
done
rm -r $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION

cd $SCRIPT_DIR/CMScripts/
