# SDCard mounting tweaks
ext2int == 1 && /emmc \/mnt\/emmc/ { sub(/\/mnt\/emmc/, "/mnt/sdcard"); print; next; }
ext2int == 1 && /sdcard \/mnt\/sdcard/ { sub(/\/mnt\/sdcard/, "/mnt/sdcard/_ExternalSD"); print; next; }
int2ext == 1 && /emmc \/mnt\/emmc/ { sub(/\/mnt\/emmc/, "/mnt/sdcard/_InternalSD"); print; next; }

# keep rest of file as is:
{ print; }