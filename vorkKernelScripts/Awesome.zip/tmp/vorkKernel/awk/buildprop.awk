# Internal SD mounting
internal == 1 && /additionalmounts/ && /emmc/ { sub(/emmc/, "sdcard/_ExternalSD"); print; next }

# keep rest of file as is:
{ print; }
