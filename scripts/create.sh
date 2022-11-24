#!/bin/bash


if petalinux-create -t project -s xilinx-k26-starterkit-v2021.1-final.bsp -n plnx_project
then
	echo 'Petalinux project created'
else
	exit
fi

mkdir -p plnx_project/hardware && cp -r $1 plnx_project/hardware
echo 'Copied Vivado project into plnx_project/hardware'

cd plnx_project
petalinux-config --get-hw-description=$1