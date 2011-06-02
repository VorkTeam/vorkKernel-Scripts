#!/sbin/sh
ui_print() {
    echo ui_print "$@" 1>&$UPDATE_CMD_PIPE;
    if [ -n "$@" ]; then
        echo ui_print 1>&$UPDATE_CMD_PIPE;
    fi
}
log() { echo "$@"; }
fatal() { ui_print "$@"; exit 1; }

log ""

basedir=`dirname $0`
BB=$basedir/busybox
awk="$BB awk"
grep="$BB grep"
chmod="$BB chmod"
chown="$BB chown"
chgrp="$BB chgrp"
cpio="$BB cpio"
find="$BB find"
gzip="$BB gzip"
gunzip="$BB gunzip"
tar="$BB tar"
errors=0
warning=0

updatename=`echo $UPDATE_FILE | $awk '{ sub(/^.*\//,"",$0); sub(/.zip$/,"",$0); print }'`
args=`echo $updatename | $awk 'BEGIN {RS="-"}; NR>2 {print}'`
kernelver=`echo $updatename | $awk 'BEGIN {RS="-"; ORS="-"}; NR<=2 {print; ORS=""}'`

ui_print ""
ui_print "Installing $kernelver"
ui_print "Developed by Benee and kiljacken"
ui_print ""
ui_print "Parsing parameters..."
flags=""
for pp in $args; do
  if [ "$pp" == "1080p" ]; then
      hdrec=1
      flags="$flags -1080p"
      continue
  fi
  if [ "$pp" == "bc" ]; then
      baconcooker=1
      flags="$flags -baconcooker"
      continue
  fi
  if [ "$pp" == "lecam" ]; then
      leCam=1
      flags="$flags -leCam"
      continue
  fi
  if [ "$pp" == "405" ]: then
      405=1
      flags="$flags -405"
      continue
  fi
  if [ "$pp" == "502" ]; then
      502=1
      flags="$flags -502"
      continue
  fi
  if [ "$pp" == "internal" ]; then
      internal=1
      flags="$flags -internal"
      continue
  fi
      errors=$((errors + 1))
      ui_print "ERROR: unknown argument -$pp"
done

if [ "$leCam" == "1" ]: then
ui_print "thanks to LeJay for his cam mod"
fi

# make sure only one ril is selected
if [ "$405" == "1" ] && [ "$502" != "1" ]; then
405flash=1
fi

if [ "$502" == "1" ] && [ "$405" != "1" ]; then
502flash=1
fi

if [ "$405" == "1" ] && [ "$502" == "1" ]; then
errors=$((errors +1))
ui_print "ERROR: Only one ril can be flashed!"
fi

if [ -n "$flags" ]; then
    ui_print "flags:$flags"
fi

if [ ! -n "$flags" ]; then
    ui_print "no flags selected"
fi

if [ $errors -gt 0 ]; then
    fatal "argument parsing failed, aborting."
fi

ui_print "Packing kernel..."

cd $basedir
if [ "$hdrec" == "1" ]; then
	if [ "$baconcooker" == "1" ]; then 
		$BB cp Images/1080p/zImageBC zImage
	else
		$BB cp Images/1080p/zImage zImage
	fi
	cline="mem=383M@0M nvmem=128M@384M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990"

	if [ "$leCam" == "1" ]; then
	  $BB cp files/Camera.apk /system/app/Camera.apk
	  $chmod 0644 /system/app/Camera.apk
	  $BB cp $basedir/files/media_profiles.xml-le1080 /system/etc/media_profiles.xml
	else
	  $BB cp $basedir/files/media_profiles.xml-1080 /system/etc/media_profiles.xml
	fi

else
	if [ "$baconcooker" == "1" ]; then 
		$BB cp Images/zImageBC zImage
	else
		$BB cp Images/zImage zImage
	fi
	cline="mem=447M@0M nvmem=64M@447M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990"

	if [ "$leCam" == "1" ]; then
	  $BB cp files/Camera.apk /system/app/Camera.apk
	  $chmod 644 /system/app/Camera.apk
	  $BB cp $basedir/files/media_profiles.xml-le720 /system/etc/media_profiles.xml
	else
	  $BB cp $basedir/files/media_profiles.xml-720 /system/etc/media_profiles.xml
	fi
fi

if [ "405flash" == "1" ]; then
	ui_print "Copying 405 RIL..."
	$BB cp files/ril/405/lge-ril.so /system/lib/lge-ril.so
fi

if [ "502flash" == "1" ]; then
	ui_print "Copying 502 RIL..."
	$BB cp files/ril/502/lge-ril.so /system/lib/lge-ril.so
fi

if [ "internal" == "1" ]; then
	ui_print "Internal is now the default storage."
	$BB cp files/vold.fstab /system/etc/vold.fstab
	$chmod 644 /system/etc/vold.fstab
	$BB cp files/90mountExt /system/etc/init.d/90mountExt
	$chmod 750 /system/etc/init.d/90mountExt
fi

ui_print "Building boot.img..."
/tmp/vorkKernel/mkbootimg --kernel /tmp/vorkKernel/zImage --ramdisk /tmp/vorkKernel/ramdisk-boot --cmdline "$cline" -o /tmp/vorkKernel/boot.img --base 0x10000000
if [ "$?" -ne 0 -o ! -f boot.img ]; then
    fatal "ERROR: Packing kernel failed!"
fi

ui_print "Flashing the kernel..."
$BB dd if=/dev/zero of=/dev/mmcblk0p5
$BB dd if=/sdcard/boot-new.img of=/dev/mmcblk0p5

ui_print "Installing kernel modules..."
$BB rm -rf /system/lib/modules
$BB cp files/lib/modules/* /system/lib/modules/*
if [ "$?" -ne 0 -o ! -d /system/lib/modules ]; then
        ui_print "WARNING: kernel modules not installed!"
        warning=$((warning + 1))
fi

ui_print ""
if [ $warning -gt 0 ]; then
    ui_print "$kernelver installed with $warning warnings."
else
    ui_print "$kernelver installed successfully, enjoy :)"
fi
