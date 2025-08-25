# Dinosaur OS

This is my customized version of Bluefin.

I'm trying to keep the changes to a minimum. The main thing I do is add libvirt. I also remove several packages that I don't use or want.

Needless to say, this image is opinionated. I don't expect many people to use this image directly. I do hope that my build script and supporting documents will be helpful to somebody making their own image though.

# Packages Installed

libvirt and qemu are installed. These packages are available in Bluefin Developer Experience (DX). However, rebasing to Bluefin DX brings a lot of additional packages such as Docker and Visual Studio Code that I don't use. I prefer to avoid adding unnecessary packages because it increases the attack surface of the system. Therefore, I created this bootc image which only includes the additions that I use.

# Packages Removed

I remove a number of packages that Bluefin adds on top of Silverblue. fuse-encfs isn't actively maintained according to the [repository](https://github.com/vgough/encfs) so I removed it.

I remove gnome-tweaks since I don't use any of its features. I also remove many of the gnome-shell-extension packages. I install my extensions in user space via the Extension Manager flatpak.

# Getting libvirt Working

Getting libvirt working requires a few steps. Obviously the packages must be installed. This image adds the libvirt and qemu packages listed in Bluefin DX's packages as well as the packages installed on my working Fedora Workstation system. See the build.sh file for the list.

I mostly lifted this methodology from Bluefin DX in the spirit of minimizing changes between this image and Bluefin. My hope is that rebasing from this image to Bluefin DX will still work, but I'm not going to test that frequently so I make no guarantees.

Only two users can create, run, and destroy virtual machines by default: the root users and members of the libvirt group. The libvirt group doesn't exist in /etc/group by default though so there's no way to add a user to it. Bluefin DX handles this with the bluefin-dx-groups script, which copies the libvirt group entry from /usr/lib/group to /etc/group. The libvirt group isn't present in the /usr/lib/group file for standard Bluefin though. My build.sh script first adds is to /usr/lib/group and then copies it from /usr/lib/group to /etc/group. Why not just add it to /etc/group? Because I'm trying to follow the Bluefin DX methodology as closely as possible. The bluefin-dx-groups script also adds all members in the wheel group to the libvirt group. The account I used day to day isn't a member of the wheel group so I don't do this step with this image. Instead users must manually be added to the libvirt group just as they would on Fedora Workstation.

The other hurdle for getting libvirt working on Bluefin is SELinux. By default /var/lib/libvirt and /var/log/libvirt are assigned the SELinux types var_lib_t and var_log_t respectively. When you try to start a virtual machine, SELinux will stop it for two reasons. First, creating /var/lib/libvirt/dnsmasq will be blocked, which prevents the virtual machine network from being created. Second, creating /var/log/libvirt will be blocked, which will prevent libvirt from logging (and it won't run if it can't log).

Bluefin DX gets around this with the libvirt-workaround systemd service. This image copies that service file into /usr/lib/systemd/system and enables it. It also uses tmpfiles.d to create /var/log/libvirt temporarily so the SELinux permissions can be set by the libvirt-workaround service (/var/lib/libvirt is created by default on Fedora so it doesn't need to be temporarily created in this fashion).

# Other Changes

I hide the Discourse and Documentation launch icons. I don't use these so they're unwanted clutter in my launcher. I also hide the System Updater. It opens a terminal and runs `ujust update` and then closes the terminal. `ujust update` updates both the bootc image and installed flatpaks. I prefer to update my system image and installed flatpaks at different intervals. I also dislike the behavior of the terminal closing once the command finishes executing. Therefore, I don't use System Updated and it's also unwanted clutter for me.

I also copy the input group from /usr/lib/group to /etc/group so I can add my user account to it. Membership in this group is necessary for using Input Remapper. I use Input Remapper to remap buttons on my trackballs.
