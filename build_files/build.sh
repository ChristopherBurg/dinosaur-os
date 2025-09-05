#!/bin/bash

set -ouex pipefail

# Add any systemd unit files and executables to the image.
rsync -rvK /ctx/system_files/ /

# Install libvirt.
/ctx/build_files/base/00-install-libvirt.sh

# Make my changes to the base Bluefin image.
/ctx/build_files/base/01-base-image-changes.sh

systemctl enable podman.socket

# Clean up.
/ctx/build_files/clean-stage.sh
mkdir -p /var/tmp &&
    chmod -R 1777 /var/tmp
ostree container commit
