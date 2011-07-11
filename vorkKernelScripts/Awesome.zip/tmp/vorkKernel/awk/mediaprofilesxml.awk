# Check camera type
/cameraId="0"/ { back=1; print; next; }
/cameraId="0"/ { back=0; print; next; }

# Make sure we edit video only
/Video/ { video=1; print; next; }
/Audio/ { video=0; print; next; }

# Check which setting we are chaning
/hd/ { hd=1; high=0; low=0; print; next; }
/high/ { hd=0; high=1; low=0; print; next; }
/low/ { hd=0; high=0; low=1; print; next; }

# Change the bitrate
/bitRate/ && back==1 && video==1 && bitrate==1 && hd==1 { sub(/12000000/, "17000000"); print; next; }
/bitRate/ && back==1 && video==1 && bitrate==1 && high==1 { sub(/6000000/, "12000000"); print; next; }
/bitRate/ && back==1 && video==1 && bitrate==1 && low==1 { sub(/128000/, "384000"); print; next; }


# keep rest of file as is:
{ print; }