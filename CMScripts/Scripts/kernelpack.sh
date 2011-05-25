#!/bin/bash

# cp $SCRIPT_DIR/CM/out/target/product/p990/system/lib/libsqlite.so /home/vork/CMScripts/Update.zip/system/lib/libsqlite.so

if [ -d $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk ]
  then
    echo Found boot.img-ramdisk

    if [ -e $SCRIPT_DIR/CMScripts/Tools/zImage ]
    then
      echo Found zImage
    else
      echo Did not find $SCRIPT_DIR/CMScripts/Tools/zImage
      exit 0
    fi
  else
    echo Did not find $SCRIPT_DIR/CMScripts/Tools/boot.img-ramdisk folder!
    exit 0
fi

cd $SCRIPT_DIR/CMScripts/Tools

./mkbootfs boot.img-ramdisk | gzip > ramdisk-boot

cp ramdisk-boot ../Awesome.zip/tmp/vorkKernel/ramdisk-boot

cd $SCRIPT_DIR/CMScripts/Awesome.zip

echo Making update.zip ...
zip -r -y -q update *
echo
echo update.zip created

echo Signing update.zip as $signed_file ...

cp ../Tools/signapk_files/testkey.* .
cp ../Tools/signapk_files/signapk.jar .

java -jar signapk.jar testkey.x509.pem testkey.pk8 update.zip $signed_file

rm -f testkey.*
rm -f signapk.jar
rm -f update.zip

if [ "$release" == "release" ]; then
	if [ -d $BUILD_DIR/LG\ P990 ]; then
	  mv $signed_file $BUILD_DIR/LG\ P990/$signed_file
	else
	  mkdir $BUILD_DIR/LG\ P990
	  mv $signed_file $BUILD_DIR/LG\ P990/$signed_file
	fi
else
   	if [ -d $BUILD_DIR/LGTEST ]; then
	  mv $signed_file $BUILD_DIR/LGTEST/$signed_file
	else
	  mkdir $BUILD_DIR/LGTEST
	  mv $signed_file $BUILD_DIR/LGTEST/$signed_file
	fi
fi

cd $SCRIPT_DIR/CMScripts/
