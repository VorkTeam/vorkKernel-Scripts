#!/bin/bash

export buildprefix=$HOME/vorkChain
ccachev=3.1.6

if [ ! -d $buildprefix/source/ccache-$ccachev ]; then
	echo Downloading ccache...
	cd $buildprefix/source/
	wget http://samba.org/ftp/ccache/ccache-$ccachev.tar.bz2
	tar -xvjf ccache-$ccachev.tar.bz2
fi

cd $buildprefix/source/ccache-$ccachev
echo Configuring ccache...
./configure
make -j`grep "processor" /proc/cpuinfo | wc -l`
sudo make install -j`grep "processor" /proc/cpuinfo | wc -l`

echo > $HOME/vorkKernel-Scripts/vorkKernelScripts/Tools/ccache.txt
cd $HOME/vorkKernel-Scripts/ 
