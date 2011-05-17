#!/bin/bash

export buildprefix=/home/$USER/Codesourcery
export prefix=/home/$USER/Codesourcery/toolchain

cd $buildprefix
#Untar the source
tar -jxvf arm-*-arm-none-eabi.src.tar.bz2

export tversion=`cat arm-*/gnu-*.txt | fgrep Version: | cut -f 2 -d : | sed s/\ //g`
export tdate=`cat arm-*/gnu-*.txt | fgrep Version: | cut -f 2 -d : | sed s/\ //g | cut -c1-7`

mkdir source
mkdir temp
mkdir temp/binutils
mkdir temp/gcc
mkdir temp/newlib
# mkdir temp/gdb

# commented gdb stuff out - optional
cp arm-$tversion-arm-none-eabi/binutils-$tversion.tar.bz2 source/binutils.tar.bz2
cp arm-$tversion-arm-none-eabi/gcc-$tversion.tar.bz2 source/gcc.tar.bz2
cp arm-$tversion-arm-none-eabi/newlib-$tversion.tar.bz2 source/newlib.tar.bz2
cp arm-$tversion-arm-none-eabi/mpc-$tversion.tar.bz2 source/mpc.tar.bz2
cp arm-$tversion-arm-none-eabi/mpfr-$tversion.tar.bz2 source/mpfr.tar.bz2
#cp arm-$tversion-arm-none-eabi/gdb-$tversion.tar.bz2 source/gdb.tar.bz2
cd source
tar -jxvf binutils.tar.bz2
tar -jxvf gcc.tar.bz2
tar -jxvf newlib.tar.bz2
tar -jxvf mpc.tar.bz2
tar -jxvf mpfr.tar.bz2
#tar -jxvf gdb.tar.bz2

mv mpc-* mpc
mv mpfr-* mpfr
cd gcc-*
mv ../mpc mpc
mv ../mpfr mpfr

cd $buildprefix/temp/binutils
make distclean
$buildprefix/source/binutils-$tdate/configure --target=arm-eabi --prefix=$prefix --disable-nls --disable-shared --disable-threads --with-gcc --with-gnu-as --with-gnu-ld --enable-interwork --enable-multilib
make -j8
make install -j8

cd $buildprefix/temp/gcc
make distclean
$buildprefix/source/gcc-*-$tdate/configure --target=arm-eabi --with-mode=thumb --with-arch=armv7-a --with-tune=cortex-a9 --with-fpu=vfpv3-d16 --with-float=softfp --prefix=$prefix --with-gcc --with-gnu-ld --with-gnu-as --disable-nls --disable-shared --disable-threads --enable-languages=c,c++ --with-newlib --with-headers=$buildprefix/source/newlib-$tdate/newlib/libc/include
make all-gcc -j8
make install-gcc -j8

# export PATH=$prefix/bin:$PATH test new style
PATH=$prefix/bin:$PATH
export PATH

cd $buildprefix/temp/newlib
make distclean # not needed for a freshly created empty directory
$buildprefix/source/newlib-$tdate/configure --target=arm-eabi --prefix=$prefix --enable-interwork --enable-multilib
make -j8
make install -j8

cd $buildprefix/temp/gcc
make -j8
make install -j8

#cd $buildprefix/temp/gdb
#$buildprefix/source/gdb-$tdate/configure --target=arm-eabi --prefix=$prefix --disable-nls
#make -j8
#make install -j8

strip $prefix/bin/*
strip $prefix/arm-eabi/bin/*
strip $prefix/libexec/gcc/arm-eabi/*/*
