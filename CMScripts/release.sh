#!/bin/bash

NOW=$(date +"%d%m%y")
sed -i 's/TESTVR/'$NOW'/g' /home/vork/CMKernelLG/lge-kernel-star/arch/arm/configs/vorkKernel*
export release=test
