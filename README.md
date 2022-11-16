# k26som-plnx-setup
This repo is a collection of instructions and scripts to help setup a minimal Petalinux system, booting from an SD card, on a production K26 SOM.

## Tools Version
Xilinx tools(Vitis, Vivado, Petalinux) release version 2021.1 is required.

## SD Card Setup
Petalinux requires a specific configuration of partitions and filesystems on the boot SD card.
This tutorial will guide you through the process of configuring it on a linux-based OS.

1. View the current partition schemes using `sudo fdisk -l`

