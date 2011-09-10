# Remove scheduler tweaks to use kernel defaults
/sched_latency_ns/ { next; }
/sched_wakeup_granularity_ns/ { next; }
/scaling_min_freq/ { next; }
/scaling_max_freq/ { next; }
/scaling_governor/ { next; }
/sampling_rate/ { next; }
device == DESIRE && /Power Management/ { print; getline; if (!$0~/avs/) {print "write /sys/module/avs/parameters/enable 1";} getline; if (!$0~/avs/) {print "write /sys/module/avs/parameters/debug 0";} next; }

# Tweak internal taskkiller
/EMPTY_APP_ADJ/ { print; getline; if (!$0~/CONTENT_PROVIDER_ADJ/) {print "    setprop ro.CONTENT_PROVIDER_ADJ 14";} next; }
/HIDDEN_APP_MEM/ { sub(/7168/, "10240"); print; next; }
/EMPTY_APP_MEM/ { sub(/8192/, "15360"); print; getline; if (!$0~/CONTENT_PROVIDER_MEM/) {print "    setprop ro.CONTENT_PROVIDER_MEM 12800";} next; }
/minfree/ { sub(/6144,7168,8192/, "10240,12800,15360"); print; next; }

# Tweak some VM stuff to, hopefully, increase battery life
/dirty_expire_centisecs/ { sub(/200/, "1000"); print; next; }
/dirty_writeback_centisecs/ { sub(/5/, "2000"); print; next; }

# keep rest of file as is:
{ print; }
