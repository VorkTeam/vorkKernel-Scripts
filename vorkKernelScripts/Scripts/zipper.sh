#!/bin/bash

cd $VORKSCRIPT_DIR/$1.zip

if [ "$1" == "Awesome" ]; then
	cpp -D DEVICE=$device tmp/vorkKernel/installkernel.pre.sh > tmp/vorkKernel/installkernel.pre.sh
fi

echo Making update.zip ...
zip -r -y -q update *
echo
echo update.zip created

mv update.zip ../$signed_file


cd $VORKSCRIPT_DIR/
