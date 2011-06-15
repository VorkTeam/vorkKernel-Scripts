#!/bin/bash

rm -rf $SCRIPT_DIR/CMScripts/Awesome.zip/system/lib/modules/*
rm $VORKSCRIPT_DIR/Tools/ramdisk-boot
rm $VORKSCRIPT_DIR/Tools/newBoot.img
rm $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/zImage*
rm $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/1080p/zImage*
if [ ! -d $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images ];then
mkdir $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images
fi
if [ ! -d $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/1080p ];then
mkdir $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/1080p
fi