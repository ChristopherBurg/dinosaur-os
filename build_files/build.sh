#!/bin/bash

set -ouex pipefail

# Right now the only thing in system_files is libvirt-workaround.service, which
# resets the SELinux permissions for /var/lib/libvirt. However, I may add more
# files in the future and rsyncing the entire structure will cover that.
rsync -rvK /ctx/system_files/ /

### Install packages
# Packages can be installed from any enabled yum repo on the image.
# RPMfusion repos are available by default in ublue main images
# List of rpmfusion packages can be found here:
# https://mirrors.rpmfusion.org/mirrorlist?path=free/fedora/updates/39/x86_64/repoview/index.html&protocol=https&redirect=1

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

# I remove fuse-encfs because according to the README in the repository, the
# project isn't actively maintained. (https://github.com/vgough/encfs)
#
# I don't like installing GNOME extensions as system packages. I far prefer to
# install them in user space using the Extension Manager flatpak.
dnf5 remove -y \
    fuse-encfs \
    gnome-tweaks \
    gnome-shell-extension-user-theme \
    gnome-shell-extension-gsconnect \
    gnome-shell-extension-appindicator \
    gnome-shell-extension-dash-to-dock \
    gnome-shell-extension-logo-menu \
    gnome-shell-extension-tailscale-gnome-qs \
    gnome-shell-extension-search-light \
    gnome-shell-extension-caffeine \
    gnome-shell-extension-blur-my-shell \
    yaru-theme \

# I typically add my user to the libvirt group so I can start up virtual machines
# without entering a sudo password. The group is missing from the standard Bluefin
# install. I took this line from /usr/lib/group from Bluefin DX.
#
# I check to verify libvirt isn't present first just in case it gets added in a
# future release.
if ! grep -q "^libvirt:" /usr/lib/group; then
    echo "libvirt:x:965:" >> /usr/lib/group
fi

# I want to append a few groups to my /etc/group file so I can add my user
# account to them. The groups that are added are listed below this function.
append_group() {
    local group_name="$1"
    if ! grep -q "^$group_name:" /etc/group; then
        echo "Appending $group_name to /etc/group"
        grep "^$group_name:" /usr/lib/group | tee -a /etc/group >/dev/null
    fi
}

# I add my account to the input group so I can use Input Remapper to remap my
# extra trackball buttons.
append_group input

# I add my account to the libvirt group so I can create, run, and destroy
# virtual machines.
append_group libvirt

# Use a COPR Example:
#
# dnf5 -y copr enable ublue-os/staging
# dnf5 -y install package
# Disable COPRs so they don't end up enabled on the final image:
# dnf5 -y copr disable ublue-os/staging

#### Example for enabling a System Unit File

systemctl enable podman.socket

# This service fixes the SELinux types for /var/lib/libvirt and /var/log/libvirt.
systemctl enable libvirt-workaround.service

systemctl enable libvirtd.service

# I don't like hyperlinks polluting my application menu. The discourse.desktop
# and documentation.desktop files simply open links to websites. Therefore, I
# set them to hidden by injecting Hidden=true into them.
#
# system-update.desktop opens a terminal and executes ujust-update. What I don't
# like is that the window closes once it's done. I'd rather open a terminal myself
# and type the command.
hide_launcher() {
    local launcher="$1"
    if [[ -f "/usr/share/applications/$launcher.desktop" ]]; then
        sed -i 's@\[Desktop Entry\]@\[Desktop Entry\]\nHidden=true@g' /usr/share/applications/"$launcher".desktop
    fi
}

# Hide the launcher for the hyperlink to the Discourse page.
hide_launcher discourse

# Hide the launcher for the hyperlink to the documentation page.
hide_launcher documentation

# Hide the launcher for launching ujust update in a terminal.
hide_launcher system-update
