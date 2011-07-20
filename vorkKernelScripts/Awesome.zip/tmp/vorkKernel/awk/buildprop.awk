# Internal SD mounting
internal == 1 && /additionalmounts/ && /emmc/ { sub(/emmc/, "sdcard/_ExternalSD"); print; next; }
/lcd_density/ && density != 0 { sub(/[1-9][0-9][0-9]/, density); rdy=1; print; next; }
rdy==1 && uitweak=1 { print; rdy=0; print "windowsmgr.max_events_per_sec=60"; next; }
/opengles/ && uitweak=1 { print "debug.sf.hw=1"; print; next; }
ring=1 && /call_ring\\.delay/ { sub(/[0-9].+/, "1000"); print; next; }

# keep rest of file as is:
{ print; }
