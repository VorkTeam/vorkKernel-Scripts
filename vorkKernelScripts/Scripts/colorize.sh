#!/bin/bash

#Colorize Output
msg() {
COL1="\e[1;32m"	#Green Bold
COL2="\e[;1m"	#Only Bold
MAIN="\e[m"	#Default color

echo -e "$COL1==>$COL2 $1$MAIN"
}
