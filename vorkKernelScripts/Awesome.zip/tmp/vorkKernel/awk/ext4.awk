# EXT4 Conversion
ext4 == 1 && /system/ && !/ext4/ { sub(/ext3/, "ext4"); sub(/wait/, "wait noauto_da_alloc"); print; next;}
ext4 == 1 && /data/ && !/ext4/ { sub(/ext3/, "ext4"); sub(/wait/, "wait noauto_da_alloc"); print; next;}

# keep rest of file as is:
{ print; }