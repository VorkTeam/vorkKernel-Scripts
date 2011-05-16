#!/bin/bash

cd $SCRIPT_DIR/CMKernelLG/lge-kernel-star

echo "Building ..."
make ARCH=arm CROSS_COMPILE=$ARM_EABI vorkKernel_defconfig

signed_file=vorkKernel-LGP990.zip

NOW=$(date +"%d%m%y")

sed -i 's/-vorkKernel-.*/-vorkKernel-'$NOW'"/g' /home/$USER/CMKernelLG/lge-kernel-star/.config

export localVersion=`cat .config | fgrep CONFIG_LOCALVERSION= | cut -f 2 -d = | sed s/\"//g`
export linuxVersion=`cat .config | fgrep "Linux kernel version: "| cut -c25-34 | sed s/\"//g`
export VERSION=$linuxVersion$localVersion

rm $SCRIPT_DIR/CMScripts/Update.zip/kernel/boot.img
rm -rf $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/*

echo Building the kernel
ARCH=arm CROSS_COMPILE=$ARM_EABI make -j`grep 'processor' /proc/cpuinfo | wc -l`
make ARCH=arm CROSS_COMPILE=$ARM_EABI INSTALL_MOD_PATH=$SCRIPT_DIR/CMScripts/Update.zip/system modules_install

cp arch/arm/boot/zImage $SCRIPT_DIR/CMScripts/Tools

cp $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/kernel/*/*.ko $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/
cp $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/kernel/*/*/*.ko $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/
cp $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/kernel/*/*/*/*.ko $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/
cp $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/kernel/*/*/*/*/*.ko $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/
rm -r $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION

# rm $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/build
# rm $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/source
# cp $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/$VERSION/kernel/drivers/net/wireless/bcm4329/wireless.ko $SCRIPT_DIR/CMScripts/Update.zip/system/lib/modules/wireless.ko

cd $SCRIPT_DIR/CMScripts/
