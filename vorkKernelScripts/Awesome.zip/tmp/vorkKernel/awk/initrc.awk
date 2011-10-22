# Remove scheduler tweaks to use kernel defaults
/sched_latency_ns/ { next; }
/sched_wakeup_granularity_ns/ { next; }
/scaling_min_freq/ { next; }
/scaling_max_freq/ { next; }
/scaling_governor/ { next; }
/sampling_rate/ { next; }
avs == 1 && /Power Management/ { print; getline; if (!$0~/avs/) {print "write /sys/module/avs/parameters/enable 1";} getline; if (!$0~/avs/) {print "write /sys/module/avs/parameters/debug 0";} next; }

# Tweak some VM stuff to, hopefully, increase battery life
/dirty_expire_centisecs/ { sub(/200/, "1000"); print; next; }
/dirty_writeback_centisecs/ { sub(/5/, "2000"); print; next; }

# keep rest of file as is:
{ print; }
