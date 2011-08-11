# SDCard mounting tweaks
ext2int == 1 && /additionalmounts/ && /emmc/ { sub(/emmc/, "sdcard/_ExternalSD"); print; next; }
int2ext == 1 && /additionalmounts/ && /emmc/ { sub(/emmc/, "sdcard/_InternalSD"); print; next; }

# UI responsiveness tweak
/max_events_per_sec/ { event=1; }

# LCD Density
END { if (event!=1) {print "windowsmgr.max_events_per_sec=60";} }
/lcd_density/ && density != 0 { sub(/[1-9][0-9][0-9]/, density); print; next; }

# Ring Tweak
ring==1 && /call_ring/ && /delay/ { sub(/[0-9].+/, "1000"); print; next; }

# keep rest of file as is:
{ print; }
