#!/bin/bash

zImageDIR=$VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/zImage
. $VORKSCRIPT_DIR/Scripts/kernelcompile.sh

mv $SOURCE_DIR/arch/arm/boot/zImage $zImageDIR

cd $VORKSCRIPT_DIR/
