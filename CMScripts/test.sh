#!/bin/bash

sed -i 's/-vorkKernel-.*/-vorkKernel-TESTVR"/g' /home/$USER/CMKernelLG/lge-kernel-star/arch/arm/configs/vorkKernel*
export release=test
