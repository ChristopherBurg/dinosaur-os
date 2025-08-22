#!/bin/bash

set -ouex pipefail

### Install packages

# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

# I pulled the libvirt package list from the Bluefin package list for the dx
# variant available here:
#
# https://github.com/ublue-os/bluefin/blob/main/packages.json
dnf5 install -y \
    libvirt \
    qemu \
	qemu-char-spice \
	qemu-device-display-virtio-gpu \
	qemu-device-display-virtio-vga \
	qemu-device-usb-redirect \
	qemu-img \
	qemu-system-x86-core \
	qemu-user-binfmt \
	qemu-user-static \

# I don't like installing GNOME extensions as system packages. I far prefer to
# install them in user space using the Extension Manager flatpak.
#
# I also dislike brew. It was janky back when I ran macOS and there are far
# better options for Linux.
dnf5 remove -y \
    gnome-tweaks \
    gnome-shell-extension-user-theme \
    gnome-shell-theme-yaru \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-logo-menu \
    gnome-shell-extension-tailscale-gnome-qs \
    gnome-shell-extension-search-light \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-blur-my-shell \
    ublue-brew \

# I typically add my user to the libvirt group so I can start up virtual machines
# without entering a sudo password. The group is missing from the standard Bluefin
# install. I took this line from /usr/lib/group from Bluefin DX.
#
# I check to verify libvirt isn't present first just in case it gets added in a
# future release.
if ! grep -q "^libvirt:" /usr/lib/group; then
    echo "libvirt:x:965:" >> /usr/lib/group
fi

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

systemctl enable libvirtd.service
