#!/bin/bash

. $HOME/vorkKernel-Scripts/vorkKernelScripts/Scripts/colorize.sh

cd $SOURCE_DIR

msg "Building ..."
make ARCH=arm CROSS_COMPILE="$ARM_EABI" vorkKernel_defconfig

export localVersion=`cat .config | fgrep CONFIG_LOCALVERSION= | cut -f 2 -d = | sed s/\"//g`
kernelVersion=`cat .config | fgrep "Linux kernel version: "| cut -c25-34 | sed s/\"//g`
if [ ! -n "$kernelVersion" ]; then
	kernelVersion=`cat .config | fgrep "Linux/arm " | cut -d: -f 1 | cut -c13-20`
fi
export linuxVersion=$kernelVersion

export VERSION=$linuxVersion$localVersion

msg "Building the kernel"
ARCH=arm CROSS_COMPILE="$ARM_EABI" make -j`grep 'processor' /proc/cpuinfo | wc -l`

cd $VORKSCRIPT_DIR/
