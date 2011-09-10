#!/bin/bash
# Static variables
devices="LGP990 XOOM DESIRE"
script_dir="~/vorkKernel-Scripts/vorkKernelScripts"
storage_dir="~/Dropbox/Public"
start_dir="`pwd`"
cores="`grep processor /proc/cpuinfo | wc -l`"
now="`date +"%Y%m%d"`"

# Functions
function die () { echo $@; exit 1; }

# Device specific functions
function LGP990() { toolchain="~/vorkChain/toolchain/bin/arm-eabi-"; }
function XOOM() { toolchain="~/vorkChain/toolchain/bin/arm-eabi-"; }
function DESIRE() { toolchain="~/vorkChain/msmqsd/toolchain/bin/arm-eabi-": }
function LGP990_zip() {
	case $1 in
		"do")   
			cp $script_dir/mdfiles/updater-binary $script_dir/Awesome.zip/META-INF/com/google/android/
			cp $script_dir/mdfiles/unpackbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/mkbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/busybox $script_dir/Awesome.zip/tmp/vorkKernel/
			cp -r $script_dir/mdfiles/ril $script_dir/Awesome.zip/tmp/vorkKernel/files
		;;
		"clean")
			rm $script_dir/Awesome.zip/META-INF/com/google/android/updater-binary
			rm $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/busybox
			rm -r $script_dir/mdfiles/ril $script_dir/Awesome.zip/tmp/vorkKernel/files
		;;
	esac
}
function XOOM_zip() {
	case $1 in
		"do")   
			cp $script_dir/mdfiles/updater-binary $script_dir/Awesome.zip/META-INF/com/google/android/
			cp $script_dir/mdfiles/unpackbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/mkbootimg $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/busybox $script_dir/Awesome.zip/tmp/vorkKernel/
			cp $script_dir/mdfiles/media_profiles.xml $script_dir/Awesome.zip/tmp/vorkKernel/files/
		;;
		"clean")
			rm $script_dir/Awesome.zip/META-INF/com/google/android/updater-binary
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
			cp $script_dir/mdfiles/updater-desire $script_dir/Awesome.zip/META-INF/com/google/android/updater-binary
			cp $script_dir/mdfiles/unpackbootimg-desire $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			cp $script_dir/mdfiles/mkbootimg-desire $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			cp $script_dir/mdfiles/busybox-desire $script_dir/Awesome.zip/tmp/vorkKernel/busybox
		;;
		"clean")
			rm $script_dir/Awesome.zip/META-INF/com/google/android/updater-binary
			rm $script_dir/Awesome.zip/tmp/vorkKernel/unpackbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/mkbootimg
			rm $script_dir/Awesome.zip/tmp/vorkKernel/busybox
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
elif [ "$release" == "test" ]; then
	zip_location=$storage_dir/TEST/vorkKernel-$build_device.zip
fi

if [ ! -d ~/vorkKernel-$build_device ]; then
	die "Could not find kernel source for $build_device"
fi

echo "Setting up kernel..."
make -C ~/vorkKernel-$build_device ARCH=arm CROSS_COMPILE="$toolchain" vorkKernel_defconfig
if [ "$?" != "0" ]; then
	die "Error setting up kernel"
fi

echo "Building kernel..."
make -C ~/vorkKernel-$build_device ARCH=arm CROSS_COMPILE="$toolchain" -j$cores
if [ "$?" != "0" ]; then
	die "Error building kernel"
fi

echo "Grabbing zImage..."
cp ~/vorkKernel-$build_device/arch/arm/boot/zImage $script_dir/Awesome.zip/tmp/vorkKernel/zImage

echo "Grabbing kernel modules..."
for module in `find ~/vorkKernel-$build_device -name *.ko`
do
    cp $module $script_dir/Awesome.zip/tmp/vorkKernel/files/lib/modules/
done

echo "Making update zip..."
echo "#!/sbin/sh" > $script_dir/Awesome.zip/tmp/vorkKernel/installkernel.sh
cpp -D DEVICE_$build_device $script_dir/mdfiles/installkernel.pre.sh | awk '/# / { next; } { print; }' >> $script_dir/Awesome.zip/tmp/vorkKernel/installkernel.sh
"$build_device"_zip do
cd $script_dir/Awesome.zip/
zip -qrj $zip_location *
cd -
"$build_device"_zip clean

if [ "$release" == "release" ]; then # Stuff for update app
	echo "Saving release information..."
	echo $now > $storage_dir/UpdateApp/version_$build_device
	
	echo "Updating Twitter..."
	python /opt/vorkBot/vorkbot.py $device
fi
