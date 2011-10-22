/scaling_governor/ { next; }
/sampling_rate/ { next; }

avs == 1 && / Power Management / { print; getline; if (!$0~/avs/) {print "write /sys/module/avs/parameters/enabled 1";} next; }

# keep rest of file as is:
{ print; }
