#!/bin/bash

cd $SOURCE_DIR

echo "Building ..."
make ARCH=arm CROSS_COMPILE="$ARM_EABI" vorkKernel_defconfig

export localVersion=`cat .config | fgrep CONFIG_LOCALVERSION= | cut -f 2 -d = | sed s/\"//g`
export linuxVersion=`cat .config | fgrep "Linux kernel version: "| cut -c25-34 | sed s/\"//g`
export VERSION=$linuxVersion$localVersion

echo Building the kernel
ARCH=arm CROSS_COMPILE="$ARM_EABI" make -j`grep 'processor' /proc/cpuinfo | wc -l`

cd $VORKSCRIPT_DIR/
