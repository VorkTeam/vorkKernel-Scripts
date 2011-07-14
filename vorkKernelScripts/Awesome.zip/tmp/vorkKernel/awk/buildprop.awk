# Internal SD mounting
internal == 1 && /additionalmounts/ && /emmc/ { sub(/emmc/, "sdcard/_ExternalSD"); print; next; }
/lcd_density/ { sub(/[1-9][0-9][0-9]/, density); print; next; }

# keep rest of file as is:
{ print; }
