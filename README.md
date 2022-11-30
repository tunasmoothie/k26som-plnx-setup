# K26 SOM Petalinux Setup Helper
This repo is a collection of instructions and scripts to help setup a minimal Petalinux system, booting from an SD card, on a production K26 SOM.

# Tools Version
Xilinx tools(Vitis, Vivado, Petalinux) release version `2021.1` is required.

Make sure to edit `env.sh` with the correct paths and `source` it before starting.

#  !!!!!(WIP)!!!!! Building Petalinux For K26 SOM + Custom Carrier Card
The provided scripts can automatically perform the project configuration, but manual configuration is done as follows:


### Build Configuration
Because the KV260 Starter Kit uses a K26 SOM identical to the production line, we can base our Petalinux project off of the KV260 BSP provided by Xilinx [HERE](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/embedded-design-tools/2021-1.html).

![image](https://user-images.githubusercontent.com/65555647/203752335-cb815c76-b4e2-4ab7-8acc-46eccb7f2afd.png)


Run `petalinux-create -t project -s xilinx-k26-starterkit-v2021.1-final.bsp` to create the Petalinux project.

`cd` into the newly created project folder and run a preliminary `petalinux-build`. Please refer to the [Common Problems](#common-problems) section at the bottom of this document if you run into any errors.

Although the K26 SOM is virtually identical to the one that comes with the KV260 Starter Kit, one minor difference is that the KV260 has its QSPI memory locked to prevent users from bricking the machine. The K26 production SOM however has no such limitations, so we must edit the Zynq MPSoC IP in the Vivado project, enabling the QSPI (*hardware/xilinx-k26-starterkit-2021.1/*) to update this descrepency.
We should also enable the the SD1 slot to allow for booting from SD card.

![image](https://user-images.githubusercontent.com/65555647/203911866-a84ecdd9-2d4b-4f73-b84e-1cac8f1c4bdf.png)

Make sure to generate bitstream and export hardware xsa (with bitstream) before exiting.

Update the changes to your Petalinux project by running `petalinux-config --get-hw-description=<newly generated xsa>`

A menu should open for you to configure Petalinux. For the purposes of this project, you should disable external dtb ({u-boot Configuation} --> {u-boot-ext-dtb}), and set the root filesystem type to EXT4 ({Image Packaging Configuration} --> {Root filesystem type}). Make sure to specify the SD device node as 'mmcblk1p2' as well. 

![image](https://user-images.githubusercontent.com/65555647/203913873-c4af23bd-a028-4a12-ba07-1c963ddbaa5d.png)

Save the changes, exit, and build again.

### Packaging



# Prebuilt Project
The prebuilt Petalinux project contains a Vivado project (located under *project_build/hardware/xilinx-k26-starterkit-2021.1/*) which has a configured Zynq Ultrascale+ MPSoC IP core. 
Future designs may reference this configuration for the K26 SOM.


# SD Card Setup
Petalinux requires a specific configuration of partitions and filesystems on the boot SD card.
This tutorial will guide you through the process of setting up the SD card and loading the boot files from your petalinux-build.

View the current partition schemes using `sudo fdisk -l`.

![image](https://user-images.githubusercontent.com/65555647/202134189-1bc00bf1-c3d1-46b6-bf5c-c16048b5525b.png) 

/dev/sdb is our SD card, and 1 partition (sdb1) is listed.


Unmount the SD card partitions using `umount /dev/sdb1`.


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


Re-mount the SD card and verify that the partitions have been correctly with `df -T`

![image](https://user-images.githubusercontent.com/65555647/202139812-fe8016c8-a943-4d14-8a68-26c7399a89c3.png)

The SD card is now ready to be loaded.


Copy `BOOT.BIN`, `boot.scr`, and `image.ub` from *<your petalinux project>/images/linux/* into the BOOT partition of your SD card.
Copy `rootfs.cpio.gz` into the ROOT partition of your SD card.

To unpack the rootfs:
```
gzip -d rootfs.cpio.gz
cpio -idm < rootfs.cpio
```

Your SD card should now be ready to boot with Petalinux.


Image Packaging Configuration 
Root filesystem type -> EXT4

# Common Problems
### During Build Process
  >ERROR: (some package) do_package_write_rpm_setscene: No suitable staging package found
     This is caused by a problem with Yocto's configuration where its tries to install nonexisting packages. The problem can be fixed by manually commenting out the sttate lines in *<project>/build/config/plnxtool.conf*
![image](https://user-images.githubusercontent.com/65555647/203755292-2019778c-c1f0-4dae-94d5-f65409db23b0.png)

  >ERROR: Nothing RPROVIDES 'misc-config' (but /home/tunasmoothie/Documents/k26som-plnx-setup/xilinx-k26-starterkit-2021.1/components/yocto/layers/meta-petalinux/recipes-core/images/petalinux-initramfs-image.bb RDEPENDS on or otherwise requires it)
    This may happen on a freshly created kv260 project on first build. The misc layer is pre-written to be included, however the layer files are not included. Since we do not need the misc layer, we may simply edit it out of *<project>/project-spec/meta-user/conf/petalinuxbsp.conf* 
  ![image](https://user-images.githubusercontent.com/65555647/203756531-cc71f6e4-2f4d-40e1-8c52-c8b59b7014b6.png)



