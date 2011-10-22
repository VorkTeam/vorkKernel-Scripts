# Remove scheduler tweaks to use kernel defaults
/sched_latency_ns/ { next; }
/sched_wakeup_granularity_ns/ { next; }
/scaling_min_freq/ { next; }
/scaling_max_freq/ { next; }
/scaling_governor/ { next; }
/sampling_rate/ { next; }

# Tweak some VM stuff to, hopefully, increase battery life
/dirty_expire_centisecs/ { sub(/200/, "1000"); print; next; }
/dirty_writeback_centisecs/ { sub(/5/, "2000"); print; next; }

# keep rest of file as is:
{ print; }
