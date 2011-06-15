#!/bin/bash

cd $SOURCE_DIR

make ARCH=arm CROSS_COMPILE="$ARM_EABI" INSTALL_MOD_PATH=$VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/files modules_install


# still build a old update.zip (kernel manager)

if [ "$release" == "release" ]; then
	make ARCH=arm CROSS_COMPILE="$ARM_EABI" INSTALL_MOD_PATH=$VORKSCRIPT_DIR/Update.zip/system modules_install
fi



for module in `find $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/files/lib/modules/$VERSION/kernel/ -name *.ko`
do
    cp $module $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/files/lib/modules/
done
rm -r $VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/files/lib/modules/$VERSION


# still build a old update.zip (kernel manager)

if [ "$release" == "release" ]; then
	for module in `find $VORKSCRIPT_DIR/Update.zip/system/lib/modules/$VERSION/kernel/ -name *.ko`
	do
	    cp $module $VORKSCRIPT_DIR/Update.zip/system/lib/modules/
	done
	rm -r $VORKSCRIPT_DIR/Update.zip/system/lib/modules/$VERSION
fi

cd $VORKSCRIPT_DIR/
