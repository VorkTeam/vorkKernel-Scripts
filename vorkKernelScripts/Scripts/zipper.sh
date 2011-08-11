#!/bin/bash

cd $VORKSCRIPT_DIR

if [ "$1" == "Awesome" ]; then
	cpp -D DEVICE_$device mdfiles/installkernel.pre.sh > mdfiles/installkernel.pre2.sh
wk '/# / { next; } { print; }' mdfiles/installkernel.pre2.sh > mdfiles/installkernel.pre3.sh
awk 'NR==1{ print "#!/sbin/sh" } { print; }' mdfiles/installkernel.pre3.sh > $1,zip/tmp/vorkKernel/installkernel.sh
fi


cd $VORKSCRIPT_DIR/$1.zip


echo Making update.zip ...
zip -r -y -q update *
echo
echo update.zip created

mv update.zip ../$signed_file


cd $VORKSCRIPT_DIR/
