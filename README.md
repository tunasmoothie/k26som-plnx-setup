# K26 SOM Petalinux Setup Tool
This repo is a collection of instructions and scripts to help setup a minimal Petalinux system, booting from an SD card, on a production K26 SOM.

## Tools Version
Xilinx tools(Vitis, Vivado, Petalinux) release version 2021.1 is required.

## SD Card Setup
Petalinux requires a specific configuration of partitions and filesystems on the boot SD card.
This tutorial will guide you through the process of configuring it on a linux-based OS.

View the current partition schemes using `sudo fdisk -l`.

![image](https://user-images.githubusercontent.com/65555647/202134189-1bc00bf1-c3d1-46b6-bf5c-c16048b5525b.png) 
/dev/sdb is our SD card, and 1 partition (sdb1) is listed.


Unmount the SD card partitions using `umount /dev/sdb`.


Use `sudo fdisk /dev/sdb` to start configuring partitions.
![image](https://user-images.githubusercontent.com/65555647/202135125-960edd1e-59fd-4859-a241-0d8b0f02b56a.png)

Delete all partitions on the SD card.
![image](https://user-images.githubusercontent.com/65555647/202136239-a5e38cbc-f744-42eb-a994-8d329b469907.png)


Petalinux requires 2 partitions, **FAT32 for boot**, and **EXT4 for rootfs**. The boot partition needs to be at least 500MB. We will create it with 1GB here, and the rest of the space will go to the rootfs partition.

![image](https://user-images.githubusercontent.com/65555647/202137099-ff2d2009-4f0c-41d8-829a-820eab09b23d.png)
![image](https://user-images.githubusercontent.com/65555647/202137142-ea56cbb2-990e-4db6-ac62-348212d48374.png)

After partitioning, enter `w` to write all changes. `fdisk` should exit after writing.
![image](https://user-images.githubusercontent.com/65555647/202137429-3972b0b8-5e6d-47a1-92ff-acaf45044302.png)


To configure the filesystem type for the partitions:
`sudo mkfs.vfat /dev/sdb1`
`sudo mkfs.ext4 /dev/sdb2`

You may also want to name the partitions with
`sudo fatlabel /dev/sdb1 BOOT`
`sudo e2label /dev/sdb2 ROOT`


6. Re-mount the SD card and verify that the paritions have been correctly with `df -T`
![image](https://user-images.githubusercontent.com/65555647/202139812-fe8016c8-a943-4d14-8a68-26c7399a89c3.png)


The SD card is now ready for use.


