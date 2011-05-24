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

./mkbootimg --kernel zImage --ramdisk ramdisk-boot --cmdline "mem=447M@0M nvmem=64M@447M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990" -o newBoot.img --base 0x10000000

cp $SCRIPT_DIR/CMScripts/Tools/newBoot.img $SCRIPT_DIR/CMScripts/Update.zip/kernel/boot.img

cd $SCRIPT_DIR/CMScripts/Update.zip

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

if [ -d $BUILD_DIR/LG\ P990 ]; then
	if [ "$release" == "release" ]; then
	  mv $signed_file $BUILD_DIR/LG\ P990/$signed_file
	else
	  mv $signed_file $BUILD_DIR/LGTEST/$signed_file
	fi
else
   	mkdir $BUILD_DIR/LG\ P990
	if [ "$release" == "release" ]; then
	  mv $signed_file $BUILD_DIR/LG\ P990/$signed_file
	else
	  mv $signed_file $BUILD_DIR/LGTEST/$signed_file
	fi
fi

cd $SCRIPT_DIR/CMScripts/
