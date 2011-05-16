#!/bin/bash

NOW=$(date +"%d%m%y")
sed -i 's/TESTVR/'$NOW'/g' /home/$USER/CMKernelLG/lge-kernel-star/arch/arm/configs/vorkKernel*
export release=test
