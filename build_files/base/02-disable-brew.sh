#!/usr/bin/env bash

set -ouex pipefail

# If Homebrew isn't installed, uupd will throw an error when it runs unless
# the --disable-module-brew argument is passed. This appends --disable-module-brew
# to the ExecStart= line in /usr/lib/systemd/system/uupd.service.
sed --in-place 's|uupd|& --disable-module-brew|' /usr/lib/systemd/system/uupd.service

# brew-setup.service installs Homebrew. It's enabled by default on Bluefin. If
# Homebrew is removed, this service will reinstall it the next time the system
# boots unless it's disable.
systemctl disable brew-setup.service
