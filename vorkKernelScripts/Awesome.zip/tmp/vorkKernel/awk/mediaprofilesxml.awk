# Check camera type
/cameraId="0"/ { back=1; print; next; }
/cameraId="1"/ { back=0; print; next; }

# Check which setting we are changing
/hd/ { hd=1; high=0; low=0; print; next; }
/high/ { hd=0; high=1; low=0; print; next; }
/low/ { hd=0; high=0; low=1; print; next; }

# Change the bitrate
back==1 && bitrate==1 && hd==1 && /Video codec/ { print; getline; sub(/[0-9]+/, "17000000"); print; next; }
back==1 && bitrate==1 && high==1 && /Video codec/ { print; getline; sub(/[0-9]+/, "12000000"); print; next; }
back==1 && bitrate==1 && low==1 && /Video codec/ { print; getline; sub(/[0-9]+/, "384000"); print; next; }

# keep rest of file as is:
{ print; }
