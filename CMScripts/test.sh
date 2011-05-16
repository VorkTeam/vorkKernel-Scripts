#!/bin/bash

sed -i 's/-vorkKernel-.*/-vorkKernel-TESTVR"/g' /home/vork/CMKernelLG/lge-kernel-star/arch/arm/configs/vorkKernel*
export release=test
