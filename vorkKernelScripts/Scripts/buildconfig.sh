#!/bin/bash

case $1 in
	1)
	  # stock kernel
	  sed -i 's/CONFIG_USE_FAKE_SHMOO_PSYCHO=y/# CONFIG_USE_FAKE_SHMOO_PSYCHO is not set/' $SOURCE_DIR/arch/arm/configs/vorkKernel_defconfig
	  sed -i 's/return 0x08000000/return 0x04000000/' $SOURCE_DIR/arch/arm/mach-tegra/odm_kit/star/query/nvodm_query.c
	  sed -i 's/#define CARVEOUT_SIZE 128/#define CARVEOUT_SIZE 64/' $SOURCE_DIR/arch/arm/mach-tegra/board-nvodm.c
	  zImageDIR=$VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/zImage
	;;
	2)
	  # ram hack with OC
	  sed -i 's/# CONFIG_USE_FAKE_SHMOO_PSYCHO is not set/CONFIG_USE_FAKE_SHMOO_PSYCHO=y/' $SOURCE_DIR/arch/arm/configs/vorkKernel_defconfig
	  sed -i 's/return 0x08000000/return 0x04000000/' $SOURCE_DIR/arch/arm/mach-tegra/odm_kit/star/query/nvodm_query.c
	  sed -i 's/#define CARVEOUT_SIZE 128/#define CARVEOUT_SIZE 64/' $SOURCE_DIR/arch/arm/mach-tegra/board-nvodm.c
	  zImageDIR=$VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/zImageBC
	;;
	3)
	  # 1080p without OC
	  sed -i 's/CONFIG_USE_FAKE_SHMOO_PSYCHO=y/# CONFIG_USE_FAKE_SHMOO_PSYCHO is not set/' $SOURCE_DIR/arch/arm/configs/vorkKernel_defconfig
	  sed -i 's/return 0x04000000/return 0x08000000/' $SOURCE_DIR/arch/arm/mach-tegra/odm_kit/star/query/nvodm_query.c
	  sed -i 's/#define CARVEOUT_SIZE 64/#define CARVEOUT_SIZE 128/' $SOURCE_DIR/arch/arm/mach-tegra/board-nvodm.c
	  zImageDIR=$VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/1080p/zImage
	;;
	4)
	  # 1080p with OC
	  sed -i 's/# CONFIG_USE_FAKE_SHMOO_PSYCHO is not set/CONFIG_USE_FAKE_SHMOO_PSYCHO=y/' $SOURCE_DIR/arch/arm/configs/vorkKernel_defconfig
	  sed -i 's/return 0x04000000/return 0x08000000/' $SOURCE_DIR/arch/arm/mach-tegra/odm_kit/star/query/nvodm_query.c
	  sed -i 's/#define CARVEOUT_SIZE 64/#define CARVEOUT_SIZE 128/' $SOURCE_DIR/arch/arm/mach-tegra/board-nvodm.c
	  zImageDIR=$VORKSCRIPT_DIR/Awesome.zip/tmp/vorkKernel/Images/1080p/zImageBC
	;;
	5)
	  # last revert
	  sed -i 's/CONFIG_USE_FAKE_SHMOO_PSYCHO=y/# CONFIG_USE_FAKE_SHMOO_PSYCHO is not set/' $SOURCE_DIR/arch/arm/configs/vorkKernel_defconfig
	  sed -i 's/return 0x08000000/return 0x04000000/' $SOURCE_DIR/arch/arm/mach-tegra/odm_kit/star/query/nvodm_query.c
	  sed -i 's/#define CARVEOUT_SIZE 128/#define CARVEOUT_SIZE 64/' $SOURCE_DIR/arch/arm/mach-tegra/board-nvodm.c
	;;
esac

if [ "$1" != "5" ]; then
	. $VORKSCRIPT_DIR/Scripts/kernelcompile.sh

	mv $SOURCE_DIR/arch/arm/boot/zImage $zImageDIR
fi

# still build a old update.zip (kernel manager)
if [ "$1" == "2" ]; then
	if [ "$release" == "release" ]; then
	cp $zImageDIR $VORKSCRIPT_DIR/Tools/zImage
	fi
fi

cd $VORKSCRIPT_DIR/
