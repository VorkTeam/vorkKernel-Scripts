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
chmod="$BB chmod"
gunzip="$BB gunzip"
cpio="$BB cpio"
find="$BB find"
gzip="$BB gzip"
warning=0
ril=0
ext4=0
bit=0
inter=0
dvalue=240
uitweak=0
ring=0

updatename=`echo $UPDATE_FILE | $awk '{ sub(/^.*\//,"",$0); sub(/.zip$/,"",$0); print }'`
kernelver=`echo $updatename | $awk 'BEGIN {RS="-"; ORS="-"}; NR<=2 {print; ORS=""}'`
args=`echo $updatename | $awk 'BEGIN {RS="-"}; NR>2 {print}'`

ui_print ""
ui_print "Installing $kernelver"
ui_print "Developed by Benee and kiljacken"
ui_print ""
ui_print "Checking ROM..."
if [[ `cat /system/build.prop` != *CyanogenMod* ]]; then
    fatal "Current ROM is not CyanogenMod! Aborting..."
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
		"internal")
			inter=1
			flags="$flags -internal"
		;;
        "405"|"502"|"606"|"622")
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
				dvalue=220
			fi
            flags="$flags -density value:$dvalue"
        ;;
        "ext4")
            ui_print "EXT4 is not officially supported!"
            ext4=1
            flags="$flags -EXT4"
        ;;
		"uitweak")
			uitweak=1
			flags="$flags -uitweak"
		;;
		"ring")
			ring=1
			flags="$flags -ring"
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
ui_print "Dumping boot image..."
$BB dd if=/dev/block/mmcblk0p5 of=$basedir/boot.old
if [ ! -f $basedir/boot.old ]; then
	fatal "ERROR: Dumping old boot image failed"
fi

ui_print "Unpacking boot image..."
ramdisk="$basedir/boot.old-ramdisk.gz"
$basedir/unpackbootimg -i $basedir/boot.old -o $basedir/ -p 0x800
if [ "$?" -ne 0 -o ! -f $ramdisk ]; then
    fatal "ERROR: Unpacking old boot image failed (ramdisk)"
fi

mkdir $basedir/ramdisk
cd $basedir/ramdisk
$gunzip -c $basedir/boot.old-ramdisk.gz | $cpio -i

if [ ! -f init.rc ]; then
    fatal "ERROR: Unpacking ramdisk failed!"
elif [ ! -f init.p990.rc ]; then
    fatal "ERROR: Invalid ramdisk!"
fi

ui_print "Applying init.rc tweaks..."
mv init.rc ../init.rc.org
mv init.p990.rc ../init.p990.rc.org
$awk -f $basedir/awk/initrc.awk ../init.rc.org > init.rc
$awk -v ext4=$ext4 -f $basedir/awk/initp990rc.awk ../init.p990.rc.org > init.p990.rc

ui_print "Build new ramdisk..."
$BB find . | $BB cpio -o -H newc | $BB gzip > $basedir/boot.img-ramdisk.gz
if [ "$?" -ne 0 -o ! -f $basedir/boot.img-ramdisk.gz ]; then
	fatal "WARNING: Ramdisk repacking failed!"
fi

cd ../

# Build boot image
ui_print "Building boot.img..."
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
cp /system/etc/media_profiles.xml .
awk -v bitrate=$bit -f $basedir/awk/mediaprofilesxml.awk media_profiles.xml > /system/etc/media_profiles.xml

cp /system/build.prop .
awk -v internal=$inter -v density=$dvalue -v uitweak=$uitweak -v ring=$ring -f $basedir/awk/buildprop.awk build.prop > /system/build.prop

cp /system/etc/vold.fstab .
awk -v internal=$inter -f $basedir/awk/voldfstab.awk vold.fstab > /system/etc/vold.fstab

# Ril installer
if [ "$ril" == "1" ]; then
    rm /system/lib/lge-ril.so
    cp $basedir/files/ril/$rildate/lge-ril.so /system/lib/lge-ril.so
fi

#ext4
if [ "$ext4" == "1" ]; then
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

ui_print ""
if [ $warning -gt 0 ]; then
    ui_print "$kernelver installed with $warning warnings."
else
    ui_print "$kernelver installed successfully. Enjoy"
fi
