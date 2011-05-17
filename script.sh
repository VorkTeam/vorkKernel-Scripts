#!/bin/bash

export buildprefix=/home/$USER/Codesourcery
export prefix=/home/$USER/Codesourcery/toolchain
export gcclv=4.5-2011.04-0
export gcc=4.5
export binv=2.21
export mpcv=0.9
export newlibv=1.19.0


cd $buildprefix

if [ ! -d source]; then mkdir source; done
if [ ! -d temp/binutils]; then mkdir -p temp/binutils
if [ ! -d temp/gcc]; then mkdir -p temp/gcc
if [ ! -d temp/newlib]; then mkdir -p temp/newlib

cd source
wget http://launchpad.net/gcc-linaro/$gcc/$gcclv/+download/gcc-linaro-$gcclv.tar.bz2
wget http://www.multiprecision.org/mpc/download/mpc-$mpcv.tar.gz
wget ftp://sources.redhat.com/pub/newlib/newlib-$newlibv.tar.gz
wget ftp://ftp.gnu.org/gnu/binutils/binutils-$binv.tar.gz

tar -xvjf gcc-linaro-$gcclv.tar.bz2
tar -xvzf binutils-$binv.tar.gz
tar -xvzf newlib-$newlibv.tar.gz
tar -xvzf mpc-$mpcv.tar.gz

mv mpc-$mpcv mpc
cd gcc-linaro-$gcclv
mv ../mpc mpc

cd $buildprefix/temp/binutils
$buildprefix/source/binutils-$binv/configure --target=arm-eabi --prefix=$prefix --disable-nls --disable-shared --disable-threads --with-gcc --with-gnu-as --with-gnu-ld --enable-interwork --enable-multilib
make -j8
make install -j8

cd $buildprefix/temp/gcc
$buildprefix/source/gcc-linaro-$gcclv/configure --target=arm-eabi --with-mode=thumb --with-arch=armv7-a --with-tune=cortex-a9 --with-fpu=vfpv3-d16 --with-float=softfp --prefix=$prefix --with-pkgversion=vorkChain_r1-LinaroBase --with-gcc --with-gnu-ld --with-gnu-as --disable-nls --disable-shared --disable-threads --enable-languages=c,c++ --with-newlib --with-headers=$buildprefix/source/newlib-$newlibv/newlib/libc/include
make all-gcc -j8
make install-gcc -j8

# export PATH=$prefix/bin:$PATH test new style
PATH=$prefix/bin:$PATH
export PATH

cd $buildprefix/temp/newlib
$buildprefix/source/newlib-$newlibv/configure --target=arm-eabi --prefix=$prefix --enable-interwork --enable-multilib
make -j8
make install -j8

cd $buildprefix/temp/gcc
make -j8
make install -j8

strip $prefix/bin/*
strip $prefix/arm-eabi/bin/*
strip $prefix/libexec/gcc/arm-eabi/*/*
