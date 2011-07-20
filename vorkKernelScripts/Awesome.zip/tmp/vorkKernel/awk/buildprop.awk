# Internal SD mounting
internal == 1 && /additionalmounts/ && /emmc/ { sub(/emmc/, "sdcard/_ExternalSD"); print; next; }
/max_events_per_sec/ { event=1; }
/debug\\.sf\\.hw/ { gpu=1; }
/lcd_density/ { if (event!=1) {print "windowsmgr.max_events_per_sec=60";} }
/lcd_density/ && density != 0 { sub(/[1-9][0-9][0-9]/, density); print; next; }
/opengles/ && uitweak==1 { if (gpu!=1) { print "debug.sf.hw=1"; } print; next; }
ring==1 && /call_ring\\.delay/ { sub(/[0-9].+/, "1000"); print; next; }

# keep rest of file as is:
{ print; }
