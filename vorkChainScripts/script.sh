#!/bin/bash

. $HOME/vorkKernel-Scripts/vorkKernelScripts/Scripts/colorize.sh

export buildprefix=$HOME/vorkChain
export prefix=$HOME/vorkChain/toolchain
gcclink=4.6-2011.07
gcclv=4.6-2011.07-0
gcc=4.6
binv=2.21.1
binvrev=a
mpcv=0.9
newlibv=1.19.0
vorkChain_revision=vorkChain_r4-LinaroBase
jobs=-j8

if [ -d $prefix/bin ]; then
   msg "Toolchain already compiled. Do you want to recompile? (y/n) "
   read CHOICE
   if [ ! $CHOICE == "y" ]; then exit 0; fi
fi

if [ ! -d $buildprefix ]; then mkdir $buildprefix; fi
cd $buildprefix

if [ ! -d source ]; then mkdir source; fi
if [ ! -d temp/binutils ]; then mkdir -p temp/binutils; fi
if [ ! -d temp/gcc ]; then mkdir -p temp/gcc; fi
if [ ! -d temp/newlib ]; then mkdir -p temp/newlib; fi

if [ ! -d $buildprefix/source/gcc-linaro-$gcclv ]; then
    msg "Downloading gcc-linaro and mpc..."
    cd $buildprefix/source/
    rm gcc-linaro-*.tar.bz2 &>/dev/null
    rm mpc-*.tar.gz&>/dev/null
    wget http://launchpad.net/gcc-linaro/$gcc/$gcclink/+download/gcc-linaro-$gcclink.tar.bz2
    wget http://www.multiprecision.org/mpc/download/mpc-$mpcv.tar.gz

    msg "Extracting gcc-linaro and mpc..."
    tar -xvjf gcc-linaro-$gcclink.tar.bz2
    tar -xvzf mpc-$mpcv.tar.gz
    
    msg "Moving mpc to gcc folder"
    mv mpc-$mpcv mpc
    cd gcc-linaro-$gcclv
    mv ../mpc mpc
fi

if [ ! -d $buildprefix/source/binutils-$binv ]; then
    msg "Downloading binutils..."
    cd $buildprefix/source/
    rm binutils-*.tar.gz &>/dev/null
    wget ftp://ftp.gnu.org/gnu/binutils/binutils-$binv$binvrev.tar.bz2
    
    msg "Extracting binutils..."
    tar -jxvf binutils-$binv$binvrev.tar.bz2
fi
    
if [ ! -d $buildprefix/source/newlib-$newlibv ]; then
    msg "Downloading newlib..."
    cd $buildprefix/source/
    rm newlib-*.tar.gz &>/dev/null
    wget http://dl.dropbox.com/u/30546529/newlib-$newlibv.tar.gz
    
    msg "Extracting newlib..."
    tar -xvzf newlib-$newlibv.tar.gz
fi

cd $buildprefix/temp/binutils
msg "Configuring binutils..."
$buildprefix/source/binutils-$binv/configure --target=arm-eabi --prefix=$prefix --disable-nls --disable-shared --disable-threads --with-gcc --with-gnu-as --with-gnu-ld --enable-interwork --enable-multilib
msg "Building binutils..."
make $jobs
msg "Installing binutils..."
make install $jobs

cd $buildprefix/temp/gcc
msg "Configuring gcc..."
$buildprefix/source/gcc-linaro-$gcclv/configure --target=arm-eabi --with-mode=thumb --with-arch=armv7-a --with-tune=cortex-a9 --with-fpu=vfpv3-d16 --with-float=softfp --prefix=$prefix --with-pkgversion=$vorkChain_revision --with-gcc --with-gnu-ld --with-gnu-as --disable-nls --disable-shared --disable-threads --enable-languages=c,c++ --with-newlib --with-headers=$buildprefix/source/newlib-$newlibv/newlib/libc/include
msg "Building bootstrap gcc..."
make all-gcc $jobs
msg "Installing bootstrap gcc..."
make install-gcc $jobs

PATH=$prefix/bin:$PATH
export PATH

cd $buildprefix/temp/newlib
msg "Configuring newlib..."
$buildprefix/source/newlib-$newlibv/configure --target=arm-eabi --prefix=$prefix --enable-interwork --enable-multilib
msg "Building newlib..."
make $jobs
msg "Installing newlib..."
make install $jobs

cd $buildprefix/temp/gcc
msg "Building gcc..."
make $jobs
msg "Installing gcc..."
make install $jobs

strip $prefix/bin/*
strip $prefix/arm-eabi/bin/*
strip $prefix/libexec/gcc/arm-eabi/*/*
