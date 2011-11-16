# 2 means active; 1 is deactivate and 0 leaves the value.

script==1 && /ACTIVE/ { sub(/[0-2]/, 0); print; next; }
script==2 && /ACTIVE/ { sub(/[0-2]/, 1); print; next; }

screenstate==1 && /SCREENSTATE/ { sub(/[0-2]/, 0); print; next; }
screenstate==2 && /SCREENSTATE/ { sub(/[0-2]/, 1); print; next; }

ring==1 && /RING/ { sub(/[0-2]/, 0); print; next; }
ring==2 && /RING/ { sub(/[0-2]/, 1); print; next; }

density != 0 && /DENSITY/ { sub(/[1-9][0-9][0-9]/, density); print; next; }
