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
#kernelver=`echo $updatename | $awk 'BEGIN {RS="-"; ORS="-"}; NR<=2 {print; ORS=""}`
args=`echo $updatename | $awk 'BEGIN {RS="-"}; NR>2 {print}'`

ui_print ""
ui_print " Installing $kernelver"
ui_print " Developed by Benee and kiljacken"
ui_print ""
ui_print "Parsing parameters..."
flags=
for pp in $args; do
  if [ "$pp" == "1080p" ]; then
      hdrec=1
      flags="$flags -1080p"
      continue
  fi
  errors=$((errors + 1))
  ui_print "ERROR: unknown argument -$pp"
done

if [ -n "$flags" ]; then
    ui_print "flags:$flags"
fi

if [ $errors -gt 0 ]; then
    fatal "argument parsing failed, aborting."
fi

ui_print "Packing kernel..."
cd $basedir
if [ "$hdrec" == "1" ]; then
mv 1080p/zImage zImage
mv 1080p/media_profiles.xml media_profiles.xml
cline="mem=383M@0M nvmem=128M@384M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990"
	else
cline="mem=447M@0M nvmem=64M@447M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990"
fi

mkbootimg --kernel zImage --ramdisk ramdisk-boot --cmdline "$cline" -o newBoot.img --base 0x10000000

cd /system/etc
cp $basedir/media_profiles.xml media_profiles.xml

