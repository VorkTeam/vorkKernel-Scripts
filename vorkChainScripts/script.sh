#!/bin/bash

gcclink=4.6-2011.09
gcclv=4.6-2011.09-1
gcc=4.6
binv=2.21.1
binvrev=a
mpcv=0.9
newlibv=1.19.0
vorkChain_revision=vorkChain_r5-LinaroBase

echo "You can build for following platforms: "
echo "1. Tegra"
echo "2. Qualcomm msm qsd6850"
echo "Enter you choice"

read platform

function die() {
    echo $@
    exit 1
}

if [ "$platform" == "2" ]; then 
	export buildprefix=$HOME/vorkChain/msmqsd
	export prefix=$HOME/vorkChain/msmqsd/toolchain
	optimization="--with-arch=armv7-a --with-tune=cortex-a8 --with-fpu=neon --with-float=softfp"
	if [ ! -d $buildprefix ]; then mkdir -p $buildprefix; fi
	cd $buildprefix
else
	export buildprefix=$HOME/vorkChain
	export prefix=$HOME/vorkChain/toolchain
	optimization="--with-arch=armv7-a --with-tune=cortex-a9 --with-fpu=vfpv3-d16 --with-float=softfp"
	if [ ! -d $buildprefix ]; then mkdir -p $buildprefix; fi
	cd $buildprefix
fi

if [ -d $prefix/bin ]; then
   read -p "Toolchain already compiled. Do you want to recompile? (y/n) " CHOICE
   if [ ! $CHOICE == "y" ]; then exit 0; fi
fi

if [ ! -d source ]; then mkdir source; fi
if [ ! -d temp/binutils ]; then mkdir -p temp/binutils; fi
if [ ! -d temp/gcc ]; then mkdir -p temp/gcc; fi
if [ ! -d temp/newlib ]; then mkdir -p temp/newlib; fi

if [ ! -d $buildprefix/source/gcc-linaro-$gcclv ]; then
    echo Downloading gcc-linaro and mpc...
    cd $buildprefix/source/
    rm gcc-linaro-*.tar.bz2 &>/dev/null
    rm mpc-*.tar.gz&>/dev/null
    wget http://launchpad.net/gcc-linaro/$gcc/$gcclink/+download/gcc-linaro-$gcclv.tar.bz2 || die "Unable to download GCC!"
    wget http://www.multiprecision.org/mpc/download/mpc-$mpcv.tar.gz || die "Unable to download MPC!"

    echo Extracting gcc-linaro and mpc...
    tar -xvjf gcc-linaro-$gcclv.tar.bz2
    tar -xvzf mpc-$mpcv.tar.gz
    
    echo Moving mpc to gcc folder
    mv mpc-$mpcv mpc
    cd gcc-linaro-$gcclv
    mv ../mpc mpc
fi

if [ ! -d $buildprefix/source/binutils-$binv ]; then
    echo Downloading binutils...
    cd $buildprefix/source/
    rm binutils-*.tar.gz &>/dev/null
    wget http://ftp.gnu.org/gnu/binutils/binutils-$binv$binvrev.tar.bz2 || die "Unable to download Binutils!"
    
    echo "Extracting binutils..."
    tar -jxvf binutils-$binv$binvrev.tar.bz2
fi
    
if [ ! -d $buildprefix/source/newlib-$newlibv ]; then
    echo Downloading newlib...
    cd $buildprefix/source/
    rm newlib-*.tar.gz &>/dev/null
    wget http://dl.dropbox.com/u/30546529/newlib-$newlibv.tar.gz || die "Unable to download Newlib!"
    
    echo Extracting newlib...
    tar -xvzf newlib-$newlibv.tar.gz
fi

cd $buildprefix/temp/binutils
echo Configuring binutils...
$buildprefix/source/binutils-$binv/configure --target=arm-eabi --prefix=$prefix --disable-nls --disable-shared --disable-threads --with-gcc --with-gnu-as --with-gnu-ld --enable-interwork --enable-multilib
echo Building binutils...
make -j`grep "processor" /proc/cpuinfo | wc -l`
echo Installing binutils...
make install -j`grep "processor" /proc/cpuinfo | wc -l`

cd $buildprefix/temp/gcc
echo Configuring gcc...
$buildprefix/source/gcc-linaro-$gcclv/configure --target=arm-eabi --with-mode=thumb $optimizations --prefix=$prefix --with-pkgversion=$vorkChain_revision --with-gcc --with-gnu-ld --with-gnu-as --disable-nls --disable-shared --disable-threads --enable-languages=c,c++ --with-newlib --with-headers=$buildprefix/source/newlib-$newlibv/newlib/libc/include
echo Building bootstrap gcc...
make all-gcc -j`grep "processor" /proc/cpuinfo | wc -l`
echo Installing bootstrap gcc...
make install-gcc -j`grep "processor" /proc/cpuinfo | wc -l`

PATH=$prefix/bin:$PATH
export PATH

cd $buildprefix/temp/newlib
echo Configuring newlib...
$buildprefix/source/newlib-$newlibv/configure --target=arm-eabi --prefix=$prefix --enable-interwork --enable-multilib
echo Building newlib...
make -j`grep "processor" /proc/cpuinfo | wc -l`
echo Installing newlib...
make install -j`grep "processor" /proc/cpuinfo | wc -l`

cd $buildprefix/temp/gcc
echo Building gcc...
make -j`grep "processor" /proc/cpuinfo | wc -l`
echo Installing gcc...
make install -j`grep "processor" /proc/cpuinfo | wc -l`

strip $prefix/bin/*
strip $prefix/arm-eabi/bin/*
strip $prefix/libexec/gcc/arm-eabi/*/*
