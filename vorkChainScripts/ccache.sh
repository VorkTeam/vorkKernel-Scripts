#!/bin/bash

export buildprefix=$HOME/vorkChain
ccachev=3.1.4

if [ ! -d $buildprefix/source/ccache-$ccachev ]; then
	echo Downloading ccache...
	cd $buildprefix/source/
	wget http://samba.org/ftp/ccache/ccache-$ccachev.tar.bz2
	tar -xvjf ccache-$ccachev.tar.bz2
fi

cd $buildprefix/source/ccache-$ccachev/
echo Configuring ccache...
./configure
make -j8
sudo make install -j8

cd $HOME/vorkKernel-Scripts/vorkKernelScripts/Tools
touch ccache.txt
