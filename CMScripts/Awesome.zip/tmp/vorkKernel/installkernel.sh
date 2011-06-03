#!/sbin/sh

ui_print() {
    echo ui_print "$@" 1>&$UPDATE_CMD_PIPE;
    if [ -n "$@" ]; then
        echo ui_print 1>&$UPDATE_CMD_PIPE;
    fi
}
fatal() { ui_print "$@"; exit 1; }

basedir=`dirname $0`
BB=$basedir/busybox
awk="$BB awk"
grep="$BB grep"
chmod="$BB chmod"
chown="$BB chown"
chgrp="$BB chgrp"
cpio="$BB cpio"
find="$BB find"
warning=0

updatename=`echo $UPDATE_FILE | $awk '{ sub(/^.*\//,"",$0); sub(/.zip$/,"",$0); print }'`
kernelver=`echo $updatename | $awk 'BEGIN {RS="-"; ORS="-"}; NR<=2 {print; ORS=""}'`
args=`echo $updatename | $awk 'BEGIN {RS="-"}; NR>2 {print}'`

ui_print ""
ui_print "Installing $kernelver"
ui_print "Developed by Benee and kiljacken"
ui_print ""
ui_print "Parsing parameters..."
flags=
for pp in $args; do
  case $pp in
  "1080p")
        hdrec=1
        flags="$flags -1080p"
  ;;
  "bc")
        baconcooker=1
        flags="$flags -baconcooker"
  ;;
  "lecam")
        lecam=1
        flags="$flags -leCam"
        ui_print "Thanks to LeJay for his cam mod"
  ;;
  "405")
        if [ "$ril502" == "1" ]; then
            fatal "ERROR: Only one RIL can be flashed!"
        fi
        ril405=1
        flags="$flags -405"
  ;;
  "502")
        if [ "$ril405" == "1" ]; then
            fatal "ERROR: Only one RIL can be flashed!"
        fi
        ril502=1
        flags="$flags -502"
  ;;
  "internal")
        internal=1
        flags="$flags -internal"
  ;;
  *)
        fatal "ERROR: Unknown argument -$pp"
  ;;
  esac
done

ui_print "Parsing complete"

if [ -n "$flags" ]; then
    ui_print "Flags: $flags"
else
    ui_print "No flags selected"
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
	  $BB rm /system/app/Camera.apk
	  $BB cp files/Camera.apk /system/app/Camera.apk
	  $chmod 0644 /system/app/Camera.apk
	  $BB rm /system/etc/media_profiles.xml
	  $BB cp $basedir/files/media_profiles.xml-le1080 /system/etc/media_profiles.xml
	  if [ "$?" -ne 0 -o ! -f /system/app/Camera.apk ! -f /system/etc/media_profiles.xml ]; then
    	    ui_print "WARNING: Adding LeCam failed!"
	    warning=$((warning + 1))
	  fi
	else
	  $BB rm /system/etc/media_profiles.xml
	  $BB cp $basedir/files/media_profiles.xml-1080 /system/etc/media_profiles.xml
	  if [ "$?" -ne 0 -o ! -f /system/etc/media_profiles.xml ]; then
            ui_print "WARNING: Copying media_profiles.xml failed!"
            warning=$((warning + 1))
          fi
	fi

else
	if [ "$baconcooker" == "1" ]; then 
		$BB cp Images/zImageBC zImage
	else
		$BB cp Images/zImage zImage
	fi
	cline="mem=447M@0M nvmem=64M@447M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990"

	if [ "$leCam" == "1" ]; then
	  $BB rm /system/app/Camera.apk
	  $BB cp files/Camera.apk /system/app/Camera.apk
	  $chmod 644 /system/app/Camera.apk
	  $BB rm /system/etc/media_profiles.xml
	  $BB cp $basedir/files/media_profiles.xml-le720 /system/etc/media_profiles.xml
          if [ "$?" -ne 0 -o ! -f /system/app/Camera.apk ! -f /system/etc/media_profiles.xml ]; then
            ui_print "WARNING: Adding LeCam failed!"
            warning=$((warning + 1))
          fi
	else
	  $BB rm /system/etc/media_profiles.xml
	  $BB cp $basedir/files/media_profiles.xml-720 /system/etc/media_profiles.xml
          if [ "$?" -ne 0 -o ! -f /system/etc/media_profiles.xml ]; then
            ui_print "WARNING: Copying media_profiles.xml failed!"
            warning=$((warning + 1))
          fi
	fi
fi

if [ "ril405" == "1" ]; then
	$BB rm /system/lib/lge-ril.so
	$BB cp files/ril/405/lge-ril.so /system/lib/lge-ril.so
        if [ "$?" -ne 0 -o ! -f /system/lib/lge-ril.so ]; then
          ui_print "WARNING: Copying 405 RIL failed!"
          warning=$((warning + 1))
        fi
fi

if [ "ril502" == "1" ]; then
	$BB rm /system/lib/lge-ril.so
	$BB cp files/ril/502/lge-ril.so /system/lib/lge-ril.so
        if [ "$?" -ne 0 -o ! -f /system/lib/lge-ril.so ]; then
          ui_print "WARNING: Copying 502 RIL failed!"
          warning=$((warning + 1))
        fi
fi

if [ "internal" == "1" ]; then
	$BB rm /system/etc/vold.fstab
	$BB cp files/vold.fstab /system/etc/vold.fstab
	$chmod 644 /system/etc/vold.fstab
	$BB cp files/90mountExt /system/etc/init.d/90mountExt
	$chmod 750 /system/etc/init.d/90mountExt
        if [ "$?" -ne 0 -o ! -f /system/etc/vold.fstab ! -f /system/etc/init.d/90mountExt ]; then
          ui_print "WARNING: Changing default storage failed!"
          warning=$((warning + 1))
        fi
fi

ui_print "Building boot.img..."
$basedir/mkbootimg --kernel $basedir/zImage --ramdisk $basedir/ramdisk-boot --cmdline "$cline" -o $basedir/boot.img --base 0x10000000
if [ "$?" -ne 0 -o ! -f boot.img ]; then
    fatal "ERROR: Packing kernel failed!"
fi

# ui_print "Flashing the kernel..."
# Test new flashing method
# $BB dd if=/dev/zero of=/dev/mmcblk0p5
# $BB dd if=$basedir/boot.img of=/dev/mmcblk0p5
# if [ "$?" -ne 0 ]; then
#     fatal "ERROR: Flashing kernel failed!"
# fi

ui_print "Installing kernel modules..."
$BB rm -rf /system/lib/modules/*
$BB cp files/lib/modules/* /system/lib/modules/
if [ "$?" -ne 0 -o ! -d /system/lib/modules ]; then
        ui_print "WARNING: kernel modules not installed!"
        warning=$((warning + 1))
fi

ui_print ""
if [ $warning -gt 0 ]; then
    ui_print "$kernelver installed with $warning warnings."
else
    ui_print "$kernelver installed successfully. Enjoy"
fi
