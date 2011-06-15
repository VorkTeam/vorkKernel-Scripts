#!/bin/bash

cd $VORKSCRIPT_DIR/Tools

./mkbootimg --kernel zImage --ramdisk ramdisk-boot --cmdline "mem=447M@0M nvmem=64M@448M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990" -o newBoot.img --base 0x10000000

mv newBoot.img $VORKSCRIPT_DIR/Update.zip/kernel/boot.img

cd $VORKSCRIPT_DIR/
