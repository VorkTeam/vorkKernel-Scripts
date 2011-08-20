# SDCard mounting tweaks
int2ext == 1 && /emmc \/mnt\/emmc/ { sub(/\/mnt\/emmc/, "/mnt/sdcard/_InternalSD"); print; next; }

# keep rest of file as is:
{ print; }