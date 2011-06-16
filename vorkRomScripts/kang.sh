#!bin/bash

export CM_DIR=$HOME/system/cyanogenmod

clear
OLDDIR=$PWD

if [ ! -n "$1" ]; then
	echo "1. make clean"
	echo "2. make clobber"
	echo "3. Build ROM"
	echo -n "Select Option: "
	read option
else
	option=$1
fi

case  $option in
  1)
	cd $CM_DIR
	make clean
	make installclean
	;;
  2)
	cd $CM_DIR
	make clobber
	;;
  3)
	cd $CM_DIR
	. build/envsetup.sh && brunch p990
	cp $CM_DIR/out/target/product/p990/update-cm-* $HOME/Dropbox/Public/
	;;
  *)
	echo "Error: not defined!"
esac
cd $OLDDIR
