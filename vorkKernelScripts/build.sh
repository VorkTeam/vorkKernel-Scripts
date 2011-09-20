#!/bin/bash
# Static variables
storage_dir="$HOME/Dropbox/Public"
source_dir="$HOME"
script_dir="$source_dir/vorkKernel-Scripts/vorkKernelScripts"
start_dir="`pwd`"
cores="`grep processor /proc/cpuinfo | wc -l`"
now="`date +"%Y%m%d"`"

# Functions
function die () { echo $@; exit 1; }

# Device variables
devices="LGP990 XOOM DESIRE"

# Device specific functions
function LGP990() { toolchain="$HOME/vorkChain/toolchain/bin/arm-eabi-"; epeen=1; }
function XOOM() { toolchain="$HOME/vorkChain/toolchain/bin/arm-eabi-"; epeen=0; }
function DESIRE() { toolchain="$HOME/vorkChain/msmqsd/toolchain/bin/arm-eabi-"; epeen=0; }
function LGP990_zip() {
	case $1 in
		"do")   
			cp $script_dir/mdfiles/update-binary $script_dir/Awesome.zip/META-INF/com/google/android/
			cp $script_dir/mdfiles/unpackbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/mkbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/busybox $script_dir/Awesome.zip/tmp/vorkKernel/
			cp -r $script_dir/mdfiles/ril $script_dir/Awesome.zip/tmp/vorkKernel/files
		;;
		"clean")
			rm $script_dir/Awesome.zip/META-INF/com/google/android/update-binary
			rm $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/busybox
			rm -r $script_dir/Awesome.zip/tmp/vorkKernel/files/ril
		;;
	esac
}
function XOOM_zip() {
	case $1 in
		"do")   
			cp $script_dir/mdfiles/update-binary $script_dir/Awesome.zip/META-INF/com/google/android/
			cp $script_dir/mdfiles/unpackbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/mkbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/busybox $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/media_profiles.xml $script_dir/Awesome.zip/tmp/vorkKernel/files/
		;;
		"clean")
			rm $script_dir/Awesome.zip/META-INF/com/google/android/update-binary
			rm $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/busybox
			rm $script_dir/Awesome.zip/tmp/vorkKernel/files/media_profiles.xml
		;;
	esac
}
function DESIRE_zip() {
	case $1 in
		"do")
			cp $script_dir/mdfiles/updater-desire $script_dir/Awesome.zip/META-INF/com/google/android/update-binary
			cp $script_dir/mdfiles/unpackbootimg-desire $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			cp $script_dir/mdfiles/mkbootimg-desire $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			cp $script_dir/mdfiles/busybox-desire $script_dir/Awesome.zip/tmp/vorkKernel/busybox
		;;
		"clean")
			rm $script_dir/Awesome.zip/META-INF/com/google/android/update-binary
			rm $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/busybox
		;;
	esac
}
function LGP990_epeen() {
	case $1 in
		"do")   
			sed -i 's/\/\/define larger_epeen/#define larger_epeen/g' $source_dir/vorkKernel-$build_device/include/linux/vorkKernel.h
		;;
		"clean")
			sed -i 's/#define larger_epeen/\/\/define larger_epeen/g' $source_dir/vorkKernel-$build_device/include/linux/vorkKernel.h
		;;
	esac
}

# Cleanup
release=
build_device=

if [ $# -gt 0 ]; then
	input=$1
else
	i=1
	for device in $devices; do
		echo "$i) $device Release"
		i=$(($i+1))
		echo "$i) $device Test"
		i=$(($i+1))
	done
	echo "Choose a device:"
	read input
fi

i=1
for device in $devices; do
	if [ "$input" == $i ]; then # This is a release build
		release="release"
		build_device=$device
		break
	fi
	i=$(($i+1))
	
	if [ "$input" == $i ]; then # This is a test build
		release="test"
		build_device=$device
		break
	fi
	i=$(($i+1))
done

if [ "$release" == "" -o "$device" == "" ]; then # No device has been chosen
	die "ERROR: Please choose a device"
fi

echo "Setting up a $build_device $release build"
$build_device
if [ "`which ccache`" != "" -a "$USE_CCACHE" == "1" ]; then # We have ccache
	toolchain="ccache $toolchain"
fi

if [ "$release" == "release" ]; then
	zip_location=$storage_dir/$build_device/vorkKernel-$now.zip
	if [ "$epeen" == "1" ]; then
		epeen_zip_location=$storage_dir/$build_device/vorkKernelEPEEN-$now.zip
	fi
elif [ "$release" == "test" ]; then
	zip_location=$storage_dir/TEST/vorkKernel-$build_device.zip
	if [ "$epeen" == "1" ]; then
		epeen_zip_location=$storage_dir/TEST/vorkKernelEPEEN-$build_device.zip
	fi
fi

if [ ! -d $source_dir/vorkKernel-$build_device ]; then
	die "Could not find kernel source for $build_device"
fi

echo "Setting up kernel..."
make -C $source_dir/vorkKernel-$build_device ARCH=arm CROSS_COMPILE="$toolchain" vorkKernel_defconfig
if [ "$?" != "0" ]; then
	die "Error setting up kernel"
fi

echo "Building kernel..."
make -C $source_dir/vorkKernel-$build_device ARCH=arm CROSS_COMPILE="$toolchain" -j$cores
if [ "$?" != "0" ]; then
	die "Error building kernel"
fi

echo "Grabbing zImage..."
cp $source_dir/vorkKernel-$build_device/arch/arm/boot/zImage $script_dir/Awesome.zip/tmp/vorkKernel/zImage

echo "Grabbing kernel modules..."
for module in `find $source_dir/vorkKernel-$build_device -name *.ko`
do
    cp $module $script_dir/Awesome.zip/tmp/vorkKernel/files/lib/modules/
done

echo "Making update zip..."
echo "#!/sbin/sh" > $script_dir/Awesome.zip/tmp/vorkKernel/installkernel.sh
cpp -D DEVICE_$build_device $script_dir/mdfiles/installkernel.pre.sh | awk '/# / { next; } { print; }' >> $script_dir/Awesome.zip/tmp/vorkKernel/installkernel.sh
"$build_device"_zip do
cd $script_dir/Awesome.zip/
zip -qr $zip_location *
cd -
"$build_device"_zip clean

if [ "$epeen" == "1" ]; then
	"$build_device"_epeen do
	echo "Setting up kernel..."
	make -C $source_dir/vorkKernel-$build_device ARCH=arm CROSS_COMPILE="$toolchain" vorkKernel_defconfig
	if [ "$?" != "0" ]; then
		die "Error setting up kernel"
	fi

	echo "Building kernel..."
	make -C $source_dir/vorkKernel-$build_device ARCH=arm CROSS_COMPILE="$toolchain" -j$cores
	if [ "$?" != "0" ]; then
		die "Error building kernel"
	fi

	echo "Grabbing zImage..."
	cp $source_dir/vorkKernel-$build_device/arch/arm/boot/zImage $script_dir/Awesome.zip/tmp/vorkKernel/zImage

	echo "Grabbing kernel modules..."
	for module in `find $source_dir/vorkKernel-$build_device -name *.ko`
	do
		cp $module $script_dir/Awesome.zip/tmp/vorkKernel/files/lib/modules/
	done
	
	echo "Making update zip..."
	echo "#!/sbin/sh" > $script_dir/Awesome.zip/tmp/vorkKernel/installkernel.sh
	cpp -D DEVICE_$build_device $script_dir/mdfiles/installkernel.pre.sh | awk '/# / { next; } { print; }' >> $script_dir/Awesome.zip/tmp/vorkKernel/installkernel.sh
	"$build_device"_zip do
	cd $script_dir/Awesome.zip/
	zip -qr $epeen_zip_location *
	cd -
	"$build_device"_zip clean
	"$build_device"_epeen clean
fi

if [ "$release" == "release" ]; then # Stuff for update app
	echo "Saving release information..."
	echo $now > $storage_dir/UpdateApp/version_$build_device
	
	echo "Updating Twitter..."
	python /opt/vorkBot/vorkbot.py $device
fi
