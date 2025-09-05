#!/usr/bin/env bash

set -ouex pipefail

# My goal is to get libvirt installed and running as it runs on my Fedora
# Workstation systems. To this end I install a list of libvirt and qemu
# packages.
#
# This list is a combination of the package list from bluefin-dx and Fedora
# Workstation. The bluefin-dx package list can be found here:
#
# https://github.com/ublue-os/bluefin/blob/main/packages.json
#
# I pulled the Fedora Workstation packages from a running installation.
#
# I left out libvirt-nss since I don't need it.
dnf5 install -y \
    libvirt \
    libvirt-gconfig \
    libvirt-glib \
    libvirt-gobject \
    libvirt-libs \
    libvirt-ssh-proxy \
    qemu \
	qemu-char-spice \
	qemu-device-display-virtio-gpu \
	qemu-device-display-virtio-vga \
	qemu-device-usb-redirect \
	qemu-img \
	qemu-system-x86-core \
	qemu-user-binfmt \
	qemu-user-static \

# I typically add my user to the libvirt group so I can start up virtual machines
# without entering a sudo password. The group is missing from the standard Bluefin
# install. I took this line from /usr/lib/group from Bluefin DX.
#
# I check to verify libvirt isn't present first just in case it gets added in a
# future release.
if ! grep -q "^libvirt:" /usr/lib/group; then
    echo "libvirt:x:965:" >> /usr/lib/group
fi

# This service fixes the SELinux types for /var/lib/libvirt and /var/log/libvirt.
systemctl enable libvirt-workaround.service

systemctl enable libvirtd.service

systemctl enable dinosaur-os-groups.service
