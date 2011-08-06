#!/sbin/sh

ui_print() {
    echo ui_print "$@" 1>&$UPDATE_CMD_PIPE;
    if [ -n "$@" ]; then
        echo ui_print 1>&$UPDATE_CMD_PIPE;
    fi
}
log () { echo "$@"; }
fatal() { ui_print "$@"; exit 1; }

basedir=`dirname $0`
BB=$basedir/busybox
awk="$BB awk"
chmod="$BB chmod"
gunzip="$BB gunzip"
cpio="$BB cpio"
find="$BB find"
gzip="$BB gzip"
warning=0
ril=0
ext4=0
bit=0
dvalue=0
ring=0
extrdy=1
int2ext=0
ext2int=0

updatename=`echo $UPDATE_FILE | $awk '{ sub(/^.*\//,"",$0); sub(/.zip$/,"",$0); print }'`
kernelver=`echo $updatename | $awk 'BEGIN {RS="-"; ORS="-"}; NR<=2 {print; ORS=""}'`
args=`echo $updatename | $awk 'BEGIN {RS="-"}; NR>2 {print}'`

log ""
log "Kernel script started. Installing $UPDATE_FILE in $basedir"
log ""
ui_print ""
ui_print "Installing $kernelver"
ui_print "Developed by Benee and kiljacken"
ui_print ""
ui_print "Checking ROM..."
cymo=`cat /system/build.prop | $awk 'tolower($0) ~ /cyanogenmod/ { printf "1"; exit 0 }'`
miui=`cat /system/build.prop | $awk 'tolower($0) ~ /miui/ { printf "1"; exit 0 }'`
if [ "$cymo" == "1" ]; then
    log "Installing on CyanogenMod"
elif [ "$miui" == "1" ]; then
    log "Installing on Miui"
else
    fatal "Current ROM is not compatible with vorkKernel! Aborting..."
fi

ui_print ""
ui_print "Parsing parameters..."
flags=
unknown=
for pp in $args; do
    case $pp in
		"bitrate")
			bit=1
			flags="$flags -bitrate"
		;;
        "ril405"|"ril502"|"ril606"|"ril622")
            if [ "$ril" == "1" ]; then
                fatal "ERROR: Only one RIL can be flashed!"
            fi
            rildate="$pp"
            ril=1
            flags="$flags -$pp"
        ;;
        "silent")
            silent=1
            flags="$flags -silent"
        ;;
        density[1-9][0-9][0-9])
			dvalue=`echo $pp | $awk '/^density[0-9]+$/ { sub("density",""); print; }'`
			if [ ! -n "$dvalue" ]; then
				dvalue=230
			fi
            flags="$flags -density value:$dvalue"
        ;;
        "ext4")
            ui_print "EXT4 is not officially supported!"
            ext4=1
            flags="$flags -EXT4"
        ;;
		"ring")
			ring=1
			flags="$flags -ring"
		;;
		"debug")
			debug=1
		;;
		"int2ext")
			int2ext=1;
			flags="$flags -int2ext"
		;;
		"ext2int")
			ext2int=1;
			flags="$flags -ext2int"
		;;
        *)
            unknown="$unknown -$pp"
        ;;
    esac
done

if [ $unknown != "" ]; then
        fatal "ERROR: Following flags are unknown $unknown"
fi

ui_print "Parsing complete"

if [ -n "$flags" ]; then
    ui_print "Flags: $flags"
else
    ui_print "No flags selected"
fi

ui_print "Packing kernel..."

cd $basedir

# Build ramdisk
log "dumping previous kernel image to $basedir/boot.old"
$BB dd if=/dev/block/mmcblk0p5 of=$basedir/boot.old
if [ ! -f $basedir/boot.old ]; then
	fatal "ERROR: Dumping old boot image failed"
fi

log "Unpacking boot image..."
log ""
ramdisk="$basedir/boot.old-ramdisk.gz"
$basedir/unpackbootimg -i $basedir/boot.old -o $basedir/ -p 0x800
if [ "$?" -ne 0 -o ! -f $ramdisk ]; then
    fatal "ERROR: Unpacking old boot image failed (ramdisk)"
fi

mkdir $basedir/ramdisk
cd $basedir/ramdisk
log "Extracting ramdisk"
$gunzip -c $basedir/boot.old-ramdisk.gz | $cpio -i

if [ ! -f init.rc ]; then
    fatal "ERROR: Unpacking ramdisk failed!"
elif [ ! -f init.p990.rc ]; then
    fatal "ERROR: Invalid ramdisk!"
fi

log "Applying init.rc tweaks..."
cp init.rc ../init.rc.org
$awk -f $basedir/awk/initrc.awk ../init.rc.org > ../init.rc.mod

FSIZE=`ls -l ../init.rc.mod | $awk '{ print $5 }'`
log "init.rc.mod filesize: $FSIZE"

if [[ -s ../init.rc.mod ]]; then
  mv ../init.rc.mod init.rc
else
  ui_print "Applying init.rc tweaks failed! Continue without tweaks"
  warning=$((warning + 1))
fi

log "Applying init.p990.rc tweaks..."
cp init.p990.rc ../init.p990.rc.org
$awk -v ext4=$ext4 -f $basedir/awk/initp990rc.awk ../init.p990.rc.org > ../init.p990.rc.mod

FSIZE=`ls -l ../init.p990.rc.mod | $awk '{ print $5 }'`
log "init.p990.rc.mod filesize: $FSIZE"

if [[ -s ../init.p990.rc.mod ]]; then
  mv ../init.p990.rc.mod init.p990.rc
else
  if [ "$ext4" == "1" ]; then
    extrdy=0
    ui_print "WARNING: Tweaking init.p990.rc failed. Script won't convert filesystem to ext4!"
    warning=$((warning + 1))
  fi
fi

log "Build new ramdisk..."
$BB find . | $BB cpio -o -H newc | $BB gzip > $basedir/boot.img-ramdisk.gz
if [ "$?" -ne 0 -o ! -f $basedir/boot.img-ramdisk.gz ]; then
	fatal "ERROR: Ramdisk repacking failed!"
fi

cd $basedir

# Build boot image
log "Building boot.img..."
$basedir/mkbootimg --kernel $basedir/zImage --ramdisk $basedir/boot.img-ramdisk.gz --cmdline "mem=383M@0M nvmem=128M@384M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990" -o $basedir/boot.img --base 0x10000000
if [ "$?" -ne 0 -o ! -f boot.img ]; then
    fatal "ERROR: Packing kernel failed!"
fi

ui_print ""
ui_print "Flashing the kernel..."
$BB dd if=/dev/zero of=/dev/block/mmcblk0p5
$BB dd if=$basedir/boot.img of=/dev/block/mmcblk0p5
if [ "$?" -ne 0 ]; then
    fatal "ERROR: Flashing kernel failed!"
fi

ui_print ""
ui_print "Installing kernel modules..."
rm -rf /system/lib/modules
cp -r files/lib/modules /system/lib/
if [ "$?" -ne 0 -o ! -d /system/lib/modules ]; then
    ui_print "WARNING: kernel modules not installed!"
    warning=$((warning + 1))
fi

ui_print ""
if [ -n "$flags" ]; then
    ui_print "Installing additional mods..."
fi

# silent cam
if [ "$silent" == "1" ]; then
    mv /system/media/audio/ui/camera_click.ogg /system/media/audio/ui/camera_click.ogg.bak
    mv /system/media/audio/ui/VideoRecord.ogg /system/media/audio/ui/VideoRecord.ogg.bak
fi

# Awk
cp /system/etc/media_profiles.xml $basedir/media_profiles.xml
$awk -v bitrate=$bit -f $basedir/awk/mediaprofilesxml.awk $basedir/media_profiles.xml > $basedir/media_profiles.xml.mod

FSIZE=`ls -l $basedir/media_profiles.xml.mod | $awk '{ print $5 }'`
log ""
log "media_profiles.xml.mod filesize: $FSIZE"
log ""
if [[ -s $basedir/media_profiles.xml.mod ]]; then
  cp $basedir/media_profiles.xml.mod /system/etc/media_profiles.xml
else
  ui_print "WARNING: Tweaking media_profiles.xml failed! Continue without tweaks"
  warning=$((warning + 1))
fi

cp /system/build.prop $basedir/build.prop
$awk -v ext2int=$ext2int -v int2ext=$int2ext -v density=$dvalue -v ring=$ring -f $basedir/awk/buildprop.awk $basedir/build.prop > $basedir/build.prop.mod

FSIZE=`ls -l $basedir/build.prop.mod | $awk '{ print $5 }'`
log ""
log "build.prop.mod filesize: $FSIZE"
log ""

if [[ -s $basedir/build.prop.mod ]]; then
  cp $basedir/build.prop.mod /system/build.prop
else
  ui_print "WARNING: Tweaking build.prop failed! Continue without tweaks"
  warning=$((warning + 1))
fi

cp /system/etc/vold.fstab $basedir/vold.fstab
$awk -v ext2int=$ext2int -v int2ext=$int2ext -f $basedir/awk/voldfstab.awk $basedir/vold.fstab > $basedir/vold.fstab.mod

FSIZE=`ls -l $basedir/vold.fstab.mod | $awk '{ print $5 }'`
log ""
log "vold.fstab.mod filesize: $FSIZE"
log ""

if [[ -s $basedir/vold.fstab.mod ]]; then
  cp $basedir/vold.fstab.mod /system/etc/vold.fstab
else
  ui_print "WARNING: Tweaking vold.fstab failed! Continue without tweaks"
  warning=$((warning + 1))
fi

# Ril installer
if [ "$ril" == "1" ]; then
    rm /system/lib/lge-ril.so
    cp $basedir/files/ril/$rildate/lge-ril.so /system/lib/lge-ril.so
fi

if [ "$debug" == "1" ]; then
    cp $basedir/files/80log /system/etc/init.d/80log
fi

#ext4
if [ "$ext4" == "1" ]; then
  if [ "$extrdy" == "1" ]; then
    umount /system
    umount /data
    
    ui_print ""
    ui_print "Converting file-systems to EXT4..."
    tune2fs -O extents,uninit_bg,dir_index /dev/block/mmcblk0p8
    e2fsck -p /dev/block/mmcblk0p8
    tune2fs -O extents,uninit_bg,dir_index /dev/block/mmcblk0p8
    e2fsck -p /dev/block/mmcblk0p8
    tune2fs -O extents,uninit_bg,dir_index /dev/block/mmcblk0p1
    e2fsck -p /dev/block/mmcblk0p1
    tune2fs -O extents,uninit_bg,dir_index /dev/block/mmcblk0p1
    e2fsck -p /dev/block/mmcblk0p1
  fi
fi

if [ "$debug" == "1" ]; then
  rm -r /sdcard/vorkDebug
  mkdir /sdcard/vorkDebug
  cp -r $basedir/. /sdcard/vorkDebug/
fi

ui_print ""
if [ $warning -gt 0 ]; then
    ui_print "$kernelver installed with $warning warnings."
else
    ui_print "$kernelver installed successfully. Enjoy"
fi
