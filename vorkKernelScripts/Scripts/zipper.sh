#!/bin/bash

. $HOME/vorkKernel-Scripts/vorkKernelScripts/Scripts/colorize.sh

cd $VORKSCRIPT_DIR

if [ "$1" == "Awesome" ]; then
	echo "#!/sbin/sh" > $1.zip/tmp/vorkKernel/installkernel.sh
	cpp -D DEVICE_$device mdfiles/installkernel.pre.sh | awk '/# / { next; } { print; }' >> $1.zip/tmp/vorkKernel/installkernel.sh
	if [ "$device" == "LGP990" ]; then
		cp -r mdfiles/ril $1.zip/tmp/vorkKernel/files
	fi
fi


cd $VORKSCRIPT_DIR/$1.zip


msg "Making update.zip ..."
zip -r -y -q update *
echo
msg "update.zip created"

mv update.zip ../$signed_file


cd $VORKSCRIPT_DIR/
