#!/usr/bin/env bash

set -eux

# Parameters.
id=ubuntu-18.04.6-desktop-amd64
disk_img="${id}.img.qcow2"
disk_img_snapshot="${id}.snapshot.qcow2"
iso="${id}.iso"

# Get image.
if [ ! -f "$iso" ]; then
  wget "http://releases.ubuntu.com/18.04/${iso}"
fi

# Go through installer manually.
if [ ! -f "$disk_img" ]; then
  qemu-img create -f qcow2 "$disk_img" 100G
  qemu-system-x86_64 \
    -cdrom "$iso" \
    -drive "file=${disk_img},format=qcow2" \
    -enable-kvm \
    -m 2G \
    -smp 2 \
  ;
fi

# Create an image based on the original post-installation image
# so as to keep a pristine post-install image.
if [ ! -f "$disk_img_snapshot" ]; then
  qemu-img \
    create \
    -b "$disk_img" \
    -f qcow2 \
    "$disk_img_snapshot" \
  ;
fi


# -cpu host -smp cores=2,threads=1,sockets=1
# -cpu host -smp 12

# Run the copy of the installed image.
qemu-system-x86_64 \
  -drive "file=${disk_img_snapshot},format=qcow2" \
  -enable-kvm \
  -m 16G \
  -smp 2 \
  -vga virtio \
  -display sdl,gl=on \
 "$@" \
;
#-vga qxl -global qxl-vga.vram_size=512
#  -device cirrus-vga,vram=9216 \
#  -vga virtio \
#  -device virtio-vga-gl,max_hostmem=1000
 
#  -device intel-hda \
