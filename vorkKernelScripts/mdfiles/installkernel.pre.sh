#ifdef DEVICE_LGP990

#define BOOT_PARTITION 		/dev/block/mmcblk0p5
#define SYSTEM_PARTITION	/dev/block/mmcblk0p1
#define DATA_PARTITION		/dev/block/mmcblk0p8

#define SECONDARY_INIT		init.p990.rc

#define BOOT_PAGESIZE 		0x800
#define BOOT_CMDLINE 		"mem=383M@0M nvmem=128M@384M loglevel=0 muic_state=1 lpj=9994240 CRC=3010002a8e458d7 vmalloc=256M brdrev=1.0 video=tegrafb console=ttyS0,115200n8 usbcore.old_scheme_first=1 tegraboot=sdmmc tegrapart=recovery:35e00:2800:800,linux:34700:1000:800,mbr:400:200:800,system:600:2bc00:800,cache:2c200:8000:800,misc:34200:400:800,userdata:38700:c0000:800 androidboot.hardware=p990"
#define BOOT_BASE			0x10000000

#define HAS_CM
#define HAS_MIUI

#define IS_PHONE

#define EXT4_RDY
#define USES_BITRATE

#endif // DEVICE_LGP990

#ifdef DEVICE_XOOM

#define BOOT_PARTITION		/dev/block/mmcblk1p7
#define SYSTEM_PARTITION	/dev/block/mmcblk1p8
#define DATA_PARTITION		/dev/block/mmcblk1p10

#define SECONDARY_INIT		init.stingray.rc

#define BOOT_PAGESIZE           0x800
#define BOOT_CMDLINE		"$(cat $basedir/boot.old-cmdline)"
#define BOOT_BASE		$(cat $basedir/boot.old-base)

#define HAS_OTHER

#endif // DEVICE_XOOM

#ifdef DEVICE_DESIRE

#define BOOT_PARTITION		/dev/mtd/mtd2
#define SYSTEM_PARTITION	/dev/mtd/mtd3
#define DATA_PARTITION		/dev/mtd/mtd5

#define SECONDARY_INIT		init.bravo.rc

#define BOOT_PAGESIZE		0x800
#define BOOT_CMDLINE 		"$(cat $basedir/boot.old-cmdline)"
#define BOOT_BASE		$(cat $basedir/boot.old-base)

#define HAS_CM
#define HAS_MIUI

#define USES_BITRATE
#define IS_PHONE

#endif // DEVICE_DESIRE

#ifdef DEVICE_LGP990
device=LGP990
#endif
#ifdef DEVICE_XOOM
device=XOOM
#endif
#ifdef DEVICE_DESIRE
device=DESIRE
#endif

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
#ifdef DEVICE_LGP990
ril=0
#endif
#ifdef USES_BITRATE
bit=0
#endif
density=0
ringsettings=0
sstatesettings=0
scriptsettings=0
#ifdef DEVICE_LGP990
screenstate=1
#else
screenstate=0
#endif
script=0
#ifdef IS_PHONE
ring=0
#endif
#ifdef EXT4_RDY
extrdy=1
#endif
#ifdef DEVICE_LGP990
int2ext=0
ext4=1
#endif

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
#ifndef HAS_OTHER
ui_print "Checking ROM..."

#ifdef HAS_CM
cymo=`cat /system/build.prop | $awk 'tolower($0) ~ /cyanogenmod/ { printf "1"; exit 0 }'`
#endif // HAS_CM

#ifdef HAS_MIUI
miui=`cat /system/build.prop | $awk 'tolower($0) ~ /miui/ { printf "1"; exit 0 }'`
#endif // HAS_MIUI

#ifdef DEVICE_DESIRE
//Make sure we're not installing on a sense rom.
sense=`cat /system/build.prop | $awk 'tolower($0) ~ /sense/ { printf "1"; exit 0 }'`
#endif // DEVICE_DESIRE

#ifdef DEVICE_LGP990
epeen=`echo $kernelver | awk 'tolower($0) ~ /epeen/ { printf "1"; exit 0 }'`

if [ "$epeen" == "1" ]; then
    ui_print ""
    ui_print ""
    ui_print ""
    ui_print "  WARNING!"
    ui_print "    You're installing E-Peen mode for LGP990."
    ui_print "    The camera and bluetooth will get unstable."
    ui_print "    After a few minutes the kernel stabilized and"
    ui_print "    they're working again."
    ui_print ""
    ui_print "    Please DON'T report this problem!"
    ui_print "    Thanks ;)"
    ui_print ""
    ui_print ""
    ui_print ""
    $BB sleep 5s
fi
#endif //DEVICE_LGP990

if [ "$cymo" == "1" ]; then
    log "Installing on CyanogenMod"
elif [ "$miui" == "1" ]; then
    log "Installing on Miui"
#ifdef DEVICE_DESIRE
elif [ "$sense" == "0" ]; then
    log "No Sense rom detected. Continue with the installation..."
#endif //DEVICE_DESIRE
else
    fatal "Current ROM is not compatible with vorkKernel! Aborting..."
fi

ui_print ""
#endif //HAS_OTHER
ui_print "Parsing parameters..."
flags=
unknown=
for pp in $args; do
    case $pp in
#ifdef USES_BITRATE
	"camera")
		bit=1
		flags="$flags -bitrate"
	;;
#endif // USES_BITRATE
#ifdef DEVICE_LGP990
	"ril405"|"ril502"|"ril606"|"ril622"|"ril725")
        	if [ "$ril" == "1" ]; then
               		fatal "ERROR: Only one RIL can be flashed!"
        	fi
           	rildate="$pp"
            	ril=1
            	flags="$flags -$pp"
        ;;
	"int2ext")
		int2ext=1;
		flags="$flags -int2ext"
	;;
#endif // DEVICE_LGP990
        "silent")
            	silent=1
            	flags="$flags -silent"
        ;;
#ifdef IS_PHONE
        density[1-9][0-9][0-9]|nodensity)
		if [ "$pp" != "nodensity" ]; then
			density=`echo $pp | $awk '/^density[0-9]+$/ { sub("density",""); print; }'`
		else
			density=240
		fi
            	flags="$flags -$pp"
        ;;
#endif
#ifdef IS_PHONE
	"ring"|"noring")
		if [ "$pp" == "ring" ]; then
			ring=2
		else
			ring=1
		fi
		flags="$flags -$pp"
		if [ "$ringsettings" == "1" ]; then
		  fatal "ERROR: Only one option for ringtone can be selected!"
		fi
		ringsettings=1
	;;
#endif
#ifndef DEVICE_LGP990
        "sstate"|"nosstate")
		if [ "$pp" == "sstate" ]; then
        		screenstate=2
		else
			screenstate=1
		fi
                flags="$flags -$pp"
		if [ "$sstatesettings" == "1" ]; then
		  fatal "ERROR: Only one option for screenstate can be selected!"
		fi
		sstatesettings=1
        ;;
#endif
        "script"|"noscript")
                if [ "$pp" == "script" ]; then
			script=2
		else
			script=1
		fi
                flags="$flags -$pp"
                if [ "$scriptsettings" == "1" ]; then
                        fatal "ERROR: Only one option for screenstate can be selected!"
                fi
                scriptsettings=1
        ;;
#ifdef DEVICE_DESIRE
	"avs")
		avs=1
		flags="$flags -avs"
		ui_print "WARNING! Your device may become unstable"
	;;
#endif
	"debug")
		debug=1
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

log "dumping previous kernel image to $basedir/boot.old"
#ifdef DEVICE_DESIRE
$chmod 777 $basedir/dump_image
$basedir/dump_image boot $basedir/boot.old
#else
$BB dd if=BOOT_PARTITION of=$basedir/boot.old
#endif //DEVICE_DESIRE
if [ ! -f $basedir/boot.old ]; then
	fatal "ERROR: Dumping old boot image failed"
fi

log "Unpacking boot image..."
log ""
ramdisk="$basedir/boot.old-ramdisk.gz"
$basedir/unpackbootimg -i $basedir/boot.old -o $basedir/ -p BOOT_PAGESIZE
if [ "$?" -ne 0 -o ! -f $ramdisk ]; then
    fatal "ERROR: Unpacking old boot image failed (ramdisk)"
fi

mkdir $basedir/ramdisk
cd $basedir/ramdisk
log "Extracting ramdisk"
$gunzip -c $basedir/boot.old-ramdisk.gz | $cpio -i

if [ ! -f init.rc ]; then
    fatal "ERROR: Unpacking ramdisk failed!"
elif [ ! -f SECONDARY_INIT ]; then
    fatal "ERROR: Invalid ramdisk!"
fi

log "Applying init.rc tweaks..."
cp init.rc ../init.rc.org
$awk -f $basedir/awk/initrc.awk ../init.rc.org > ../init.rc.mod
#ifdef DEVICE_DESIRE
cp init.bravo.rc ../init.bravo.org
$awk -v avs=$avs -f $basedir/awk/initbravo.awk ../init.bravo.org > ../init.bravo.mod
#endif //DEVICE_DESIRE


FSIZE=`ls -l ../init.rc.mod | $awk '{ print $5 }'`
log "init.rc.mod filesize: $FSIZE"

if [[ -s ../init.rc.mod ]]; then
  mv ../init.rc.mod init.rc
else
  ui_print "Applying init.rc tweaks failed! Continue without tweaks"
  warning=$((warning + 1))
fi

#ifdef DEVICE_DESIRE
FSIZE=`ls -l ../init.bravo.mod | $awk '{ print $5 }'`
log "init.bravo.mod filesize: $FSIZE"

if [[ -s ../init.bravo.mod ]]; then
  mv ../init.bravo.mod init.bravo.rc
else
  ui_print "Applying init.bravo.rc tweaks failed! Continue without tweaks"
  warning=$((warning + 1))
fi
#endif //DEVICE_DESIRE

#ifdef EXT4_RDY
log "Applying "SECONDARY_INIT" tweaks..."
cp SECONDARY_INIT ../SECONDARY_INIT.org
$awk -v ext4=$ext4 -f $basedir/awk/ext4.awk ../SECONDARY_INIT.org > ../SECONDARY_INIT.mod

FSIZE=`ls -l ../SECONDARY_INIT.mod | $awk '{ print $5 }'`
log SECONDARY_INIT".mod filesize: $FSIZE"

if [[ -s ../SECONDARY_INIT.mod ]]; then
  mv ../SECONDARY_INIT.mod SECONDARY_INIT
else
  if [ "$ext4" == "1" ]; then
    extrdy=0
    ui_print "WARNING: Tweaking "SECONDARY_INIT" failed. Script won't convert filesystem to ext4!"
    warning=$((warning + 1))
  fi
fi
#endif

log "Build new ramdisk..."
$BB find . | $BB cpio -o -H newc | $BB gzip > $basedir/boot.img-ramdisk.gz
if [ "$?" -ne 0 -o ! -f $basedir/boot.img-ramdisk.gz ]; then
	fatal "ERROR: Ramdisk repacking failed!"
fi

cd $basedir

log "Building boot.img..."
$basedir/mkbootimg --kernel $basedir/zImage --ramdisk $basedir/boot.img-ramdisk.gz --cmdline BOOT_CMDLINE -o $basedir/boot.img --base BOOT_BASE
if [ "$?" -ne 0 -o ! -f boot.img ]; then
    fatal "ERROR: Packing kernel failed!"
fi

ui_print ""
ui_print "Flashing the kernel..."
#ifdef DEVICE_DESIRE
$chmod 777 $basedir/flash_image
$basedir/flash_image boot $basedir/boot.img
#else
$BB dd if=/dev/zero of=BOOT_PARTITION
$BB dd if=$basedir/boot.img of=BOOT_PARTITION
if [ "$?" -ne 0 ]; then
    fatal "ERROR: Flashing kernel failed!"
fi
#endif //DEVICE_DESIRE

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

$BB mount /data
cp $basedir/files/90vktweak /system/etc/init.d/90vktweak
if [ ! -f /data/local/vktweak.conf ]
    cp $basedir/files/vktweak.conf /data/local/vktweak.conf
else
    ui_print "Applying tweaks to vktweak.conf"
    cp /data/local/vktweak.conf $basedir/vktweak.conf
    $awk -v ring=$ring -v screenstate=$screenstate -v script=$script -v density=$density -f $basedir/awk/vorkconf.awk $basedir/vktweak.conf > $basedir/vktweak.conf.mod
    cp -f $basedir/vktweak.conf.mod /data/local/vktweak.conf
fi
chmod 755 /system/etc/init.d/90vktweak

if [ "$silent" == "1" ]; then
    mv /system/media/audio/ui/camera_click.ogg /system/media/audio/ui/camera_click.ogg.bak
    mv /system/media/audio/ui/VideoRecord.ogg /system/media/audio/ui/VideoRecord.ogg.bak
fi

#ifdef USES_BITRATE
#ifdef DEVICE_XOOM
cp $basedir/files/media_profiles.xml /system/etc/media_profiles.xml
#else
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
#endif //DEVICE_XOOM
#endif // USES_BITRATE

cp /system/build.prop $basedir/build.prop
#ifdef DEVICE_LGP990
$awk -v ext2int=$ext2int -v int2ext=$int2ext -v density=$dvalue -v ring=$ring -f $basedir/awk/buildprop.awk $basedir/build.prop > $basedir/build.prop.mod
#else
$awk -v density=$dvalue -v ring=$ring -f $basedir/awk/buildprop.awk $basedir/build.prop > $basedir/build.prop.mod
#endif // DEVICE_LGP990

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

#ifdef DEVICE_LGP990
cp /system/etc/vold.fstab $basedir/vold.fstab
$awk -v int2ext=$int2ext -f $basedir/awk/voldfstab.awk $basedir/vold.fstab > $basedir/vold.fstab.mod

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
#endif // DEVICE_LGP990

#ifdef DEVICE_LGP990
if [ "$ril" == "1" ]; then
    rm /system/lib/lge-ril.so
    cp $basedir/files/ril/$rildate/lge-ril.so /system/lib/lge-ril.so
fi
#endif // DEVICE_LGP990

if [ "$debug" == "1" ]; then
    cp $basedir/files/80log /system/etc/init.d/80log
	chmod 755 /system/etc/init.d/80log
fi

#ifdef EXT4_RDY
if [ "$ext4" == "1" ]; then
  if [ "$extrdy" == "1" ]; then
    umount /system
    umount /data
    
    ui_print ""
    ui_print "Converting file-systems to EXT4..."
    tune2fs -O extents,uninit_bg,dir_index DATA_PARTITION
    e2fsck -p DATA_PARTITION
    tune2fs -O extents,uninit_bg,dir_index DATA_PARTITION
    e2fsck -p DATA_PARTITION
    tune2fs -O extents,uninit_bg,dir_index SYSTEM_PARTITION
    e2fsck -p SYSTEM_PARTITION
    tune2fs -O extents,uninit_bg,dir_index SYSTEM_PARTITION
    e2fsck -p SYSTEM_PARTITION
  fi
fi
#endif

if [ -n "$flags" ]; then
    ui_print ""
fi

if [ "$debug" == "1" ]; then
  rm -r /sdcard/vorkDebug
  mkdir /sdcard/vorkDebug
  cp -r $basedir/. /sdcard/vorkDebug/
fi

if [ $warning -gt 0 ]; then
    ui_print "$kernelver installed with $warning warnings."
else
    ui_print "$kernelver installed successfully. Enjoy"
fi
