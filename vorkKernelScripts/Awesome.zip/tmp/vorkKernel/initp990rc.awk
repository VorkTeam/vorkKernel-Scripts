# EXT4 Conversion
ext4 == 1 && /system/ { sub(/ext3/, "ext4"); sub(/noatime/, "noatime noauto_da_alloc"); print; next; }
ext4 == 1 && /data/ { sub(/ext3/, "ext4"); sub(/noatime/, "noatime noauto_da_alloc"); print; next; }

# keep rest of file as is:
{ print; }
