# Check camera type
/cameraId="0"/ { back=1; print; next; }
/cameraId="1"/ { back=0; print; next; }

# Check for XOOM
/VideoEncoderCap name/ { vidcap=1; print; next; }
/h264/ { h264=1; print; next; }
/m4v/ { m4v=1; print; next; }

# Check which setting we are changing (LGP990)
/hd/ { hd=1; high=0; low=0; print; next; }
/high/ { hd=0; high=1; low=0; print; next; }
/low/ { hd=0; high=0; low=1; print; next; }

# Check which setting we are changing (XOOM)
/qcif/ { qcif=1; cif=0; p480=0; p720=0; tqcif=0; tcif=0; t480p=0; t720p=0; t1080p=0; print; next; }
/cif/ { qcif=0; cif=1; p480=0; p720=0; tqcif=0; tcif=0; t480p=0; t720p=0; t1080p=0; print; next; }
/480p/ { qcif=0; cif=0; p480=1; p720=0; tqcif=0; tcif=0; t480p=0; t720p=0; t1080p=0; print; next; }
/720p/ { qcif=0; cif=0; p480=0; p720=1; tqcif=0; tcif=0; t480p=0; t720p=0; t1080p=0; print; next; }
/timelapseqcif/ { qcif=0; cif=0; p480=0; p720=0; tqcif=1; tcif=0; t480p=0; t720p=0; t1080p=0; print; next; }
/timelapsecif/ { qcif=0; cif=0; p480=0; p720=0; tqcif=0; tcif=1; t480p=0; t720p=0; t1080p=0; print; next; }
/timelapse480p/ { qcif=0; cif=0; p480=0; p720=0; tqcif=0; tcif=0; t480p=1; t720p=0; t1080p=0; print; next; }
/timelapse720p/ { qcif=0; cif=0; p480=0; p720=0; tqcif=0; tcif=0; t480p=0; t720p=1; t1080p=0; print; next; }
/timelapse1080p/ { qcif=0; cif=0; p480=0; p720=0; tqcif=0; tcif=0; t480p=0; t720p=0; t1080p=1; print; next; }

# Change the bitrate (XOOM)
device==XOOM && back==1 && bitrate==1 && qcif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==1 && bitrate==1 && cif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==1 && bitrate==1 && p480==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; getline; print; getline; sub(/[0-9]+/, "12000000"); print; next; }
device==XOOM && back==1 && bitrate==1 && p720==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; getline; print; getline; sub(/[0-9]+/, "17000000"); print; next; }
device==XOOM && back==1 && bitrate==1 && tqcif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==1 && bitrate==1 && tcif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==1 && bitrate==1 && t480p==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==1 && bitrate==1 && t720p==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; getline; print; getline; sub(/[0-9]+/, "17000000"); print; next; }
device==XOOM && back==1 && bitrate==1 && t1080p==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; getline; print; getline; sub(/[0-9]+/, "20000000"); print; next; }

device==XOOM && bitrate==1 && back==1 && /ImageEncoding quality/ { sub(/[0-9]+/, "100"); print; getline; sub(/[0-9]+/, "99"); print; getline; sub(/[0-9]+/, "95"); print; getline; sub(/[0-9]+/, "90000000"); print; next; }

device==XOOM && back==0 && bitrate==1 && qcif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==0 && bitrate==1 && cif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==0 && bitrate==1 && p480==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; getline; print; getline; sub(/[0-9]+/, "17000000"); print; next; }
device==XOOM && back==0 && bitrate==1 && p480==1 && /width/ { sub(/[0-9]+/, "1280"); print; next; }
device==XOOM && back==0 && bitrate==1 && p480==1 && /height/ { sub(/[0-9]+/, "720"); print; next; }
device==XOOM && bitrate==1 && /EncoderOutputFileFormat name/ { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==0 && bitrate==1 && tqcif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==0 && bitrate==1 && tcif==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; next; }
device==XOOM && back==0 && bitrate==1 && t480p==1 && /EncoderProfile / { sub(/3gp/, "mp4"); print; getline; print; getline; sub(/[0-9]+/, "17000000"); print; next; }
device==XOOM && back==0 && bitrate==1 && t480p==1 && /width/ { sub(/[0-9]+/, "1280"); print; next; }
device==XOOM && back==0 && bitrate==1 && t480p==1 && /height/ { sub(/[0-9]+/, "720"); print; next; }

device==XOOM && bitrate==1 && back==0 && /ImageEncoding quality/ { sub(/[0-9]+/, "100"); print; getline; sub(/[0-9]+/, "99"); print; getline; sub(/[0-9]+/, "95"); print; getline; sub(/[0-9]+/, "250000000"); print; next; }

device==XOOM && bitrate==1 && /EncoderOutputFileFormat name/ { sub(/3gp/, "mp4"); print; next; }

device==XOOM && bitrate==1 && vidcap==1 && h264==1 && /maxBitRate/ { sub(/maxBitRate=\"[0-9]+\"/, "maxBitRate=\"50000000\""); print; next; }
device==XOOM && bitrate==1 && vidcap==1 && m4v==1 && /maxBitRate/ { sub(/maxBitRate=\"[0-9]+/, "maxBitRate=\"25000000\""); print; next; }


# Change the bitrate (LGP990)
device==LGP990 && back==1 && bitrate==1 && hd==1 && /Video codec/ { print; getline; sub(/[0-9]+/, "17000000"); print; next; }
device==LGP990 && back==1 && bitrate==1 && high==1 && /Video codec/ { print; getline; sub(/[0-9]+/, "12000000"); print; next; }
device==LGP990 && back==1 && bitrate==1 && low==1 && /Video codec/ { print; getline; sub(/[0-9]+/, "384000"); print; next; }


# keep rest of file as is:
{ print; }
