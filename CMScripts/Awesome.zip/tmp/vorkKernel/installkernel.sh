#!/sbin/sh
ui_print() {
    echo ui_print "$@" 1>&$UPDATE_CMD_PIPE;
    if [ -n "$@" ]; then
        echo ui_print 1>&$UPDATE_CMD_PIPE;
    fi
}
log() { echo "$@"; }
fatal() { ui_print "$@"; exit 1; }

log ""

basedir=`dirname $0`
BB=$basedir/busybox
awk="$BB awk"
grep="$BB grep"
chmod="$BB chmod"
chown="$BB chown"
chgrp="$BB chgrp"
cpio="$BB cpio"
find="$BB find"
gzip="$BB gzip"
gunzip="$BB gunzip"
tar="$BB tar"
errors=0
warning=0

updatename=`echo $UPDATE_FILE | $awk '{ sub(/^.*\//,"",$0); sub(/.zip$/,"",$0); print }'`
#kernelver=`echo $updatename | $awk 'BEGIN {RS="-"; ORS="-"}; NR<=2 {print; ORS=""}`
args=`echo $updatename | $awk 'BEGIN {RS="-"}; NR>2 {print}'`

ui_print ""
ui_print " Installing $kernelver"
ui_print " Developed by Benee and kiljacken"
ui_print ""
ui_print "Parsing parameters..."
flags=
for pp in $args; do
  if [ "$pp" == "1080p" ]; then
      hdrec=1
      flags="$flags -1080p"
  elif [ "$pp" == "highres" ]; then
      highres=1
      flags="$flags -highres"
  else
      errors=$((errors + 1))
      ui_print "ERROR: unknown argument -$pp"
  fi
done

if [ -n "$flags" ]; then
    ui_print "flags:$flags"
fi

if [ $errors -gt 0 ]; then
    fatal "argument parsing failed, aborting."
fi

ui_print "Packing kernel..."
cd $basedir
if [ "$hdrec" == "1" ]; then
mv 1080p/boot.img boot.img
mv 1080p/media_profiles.xml media_profiles.xml
fi
if [ "$highres" == "1"]; then
sed -n "s/lcd_density=240/lcd_density=190/" /system/build.prop
fi

cd /system/etc
cp $basedir/media_profiles.xml media_profiles.xml
