# k26som-plnx-setup
This repo is a collection of instructions and scripts to help setup a minimal Petalinux system, booting from an SD card, on a production K26 SOM.

## Tools Version
Xilinx tools(Vitis, Vivado, Petalinux) release version 2021.1 is required.

## SD Card Setup
Petalinux requires a specific configuration of partitions and filesystems on the boot SD card.
This tutorial will guide you through the process of configuring it on a linux-based OS.

1. View the current partition schemes using `sudo fdisk -l`
![image](https://user-images.githubusercontent.com/65555647/202134189-1bc00bf1-c3d1-46b6-bf5c-c16048b5525b.png)

/dev/sdb is our SD card, and 1 partition (sdb1) is listed.

2. Unmount the SD card partitions using `umount /dev/<partition>`
![image](https://user-images.githubusercontent.com/65555647/202135999-f253deb3-9455-44fd-9109-82ebc826c369.png)


3. Use `sudo fdisk /dev/<SD card>` to start configuring partitions
![image](https://user-images.githubusercontent.com/65555647/202135125-960edd1e-59fd-4859-a241-0d8b0f02b56a.png)

Delete all parit

