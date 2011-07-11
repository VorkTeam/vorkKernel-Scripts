internal == 1 && /emmc/ && /\/mnt\/emmc/ { sub(/\/mnt\/emmc/, "/mnt/sdcard"); print; next; }
internal == 1 && /sdcard/ && /\/mnt\/sdcard/ { sub(/\/mnt\/sdcard/, "/mnt/sdcard/_ExternalSD"); print; next; }

# keep rest of file as is:
{ print; }