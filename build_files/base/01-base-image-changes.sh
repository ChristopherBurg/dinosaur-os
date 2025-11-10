#!/usr/bin/env bash

set -ouex pipefail

# I remove fuse-encfs because according to the README in the repository, the
# project isn't actively maintained. (https://github.com/vgough/encfs)
#
# I don't like installing GNOME extensions as system packages. I far prefer to
# install them in user space using the Extension Manager flatpak.
dnf5 remove -y \
    fuse-encfs \
    gnome-tweaks \
#    gnome-shell-extension-user-theme \
#    gnome-shell-extension-gsconnect \
#    gnome-shell-extension-appindicator \
#    gnome-shell-extension-dash-to-dock \
#    gnome-shell-extension-logo-menu \
#    gnome-shell-extension-tailscale-gnome-qs \
#    gnome-shell-extension-search-light \
#    gnome-shell-extension-caffeine \
#    gnome-shell-extension-blur-my-shell \
    yaru-theme \

# Staring in November 2025, Bluefin started installing the default GNOME
# extensions from git. Because of this, I now remove the directories for each
# extension.

# Remove the AppIndicator extension.
rm -rf /usr/share/gnome-shell/extensions/appindicatorsupport@rgcjonas.gmail.com/

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
