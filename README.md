# Dinosaur OS

This is my customized version of Bluefin.

I'm trying to keep the changes to a minimum. The main things I do are install and configure libvirt and facilitate the removal of Homebrew. I also remove several packages that I don't use or want.

This image is opinionated. I don't expect many people to use this image directly. I do hope that my build script and supporting documents will be helpful to somebody making their own image though.

# Packages Installed

libvirt and qemu are installed. These packages are available in Bluefin Developer Experience (DX). However, rebasing to Bluefin DX brings a lot of additional packages such as Docker and Visual Studio Code that I don't use. I prefer to avoid adding unnecessary packages because they increases the attack surface of the system.

# Packages Removed

I remove a number of packages that Bluefin adds on top of Silverblue. fuse-encfs isn't actively maintained according to the [repository](https://github.com/vgough/encfs) so I remove it.

I remove gnome-tweaks since I don't use any of its features. I also remove the GNOME extensions.

# Getting libvirt Working

Getting libvirt working requires a few steps. Obviously the packages must be installed. This image adds the libvirt and qemu packages listed in Bluefin DX's packages as well as the packages installed on my working Fedora Workstation system. See the build.sh file for the list.

I mostly lifted this methodology from Bluefin DX in the spirit of minimizing changes between this image and Bluefin. My hope is that rebasing from this image to Bluefin DX will still work, but I'm not going to test that frequently so I make no guarantees.

Only two users can create, run, and destroy virtual machines by default: the root users and members of the libvirt group. The libvirt group doesn't exist in /etc/group by default though so there's no way to add a user to it. Bluefin DX handles this with the bluefin-dx-groups script, which copies the libvirt group entry from /usr/lib/group to /etc/group. The libvirt group isn't present in the /usr/lib/group file for standard Bluefin though. My build.sh script first adds is to /usr/lib/group and then copies it from /usr/lib/group to /etc/group. Why not just add it to /etc/group? Because I'm trying to follow the Bluefin DX methodology as closely as possible. The bluefin-dx-groups script also adds all members in the wheel group to the libvirt group. The account I used day to day isn't a member of the wheel group so I don't do this step with this image. Instead users must manually be added to the libvirt group just as they would on Fedora Workstation.

The other hurdle for getting libvirt working on Bluefin is SELinux. By default /var/lib/libvirt and /var/log/libvirt are assigned the SELinux types var_lib_t and var_log_t respectively. When you try to start a virtual machine, SELinux will stop it for two reasons. First, creating /var/lib/libvirt/dnsmasq will be blocked, which prevents the virtual machine network from being created. Second, creating /var/log/libvirt will be blocked, which will prevent libvirt from logging (and it won't run if it can't log).

Bluefin DX gets around this with the libvirt-workaround systemd service. This image copies that service file into /usr/lib/systemd/system and enables it. It also uses tmpfiles.d to create /var/log/libvirt temporarily so the SELinux permissions can be set by the libvirt-workaround service (/var/lib/libvirt is created by default on Fedora so it doesn't need to be temporarily created in this fashion).

# Disable Brew

Homebrew doesn't work properly unless you're using a user account with a UID of 1000. On a Fedora based system like Bluefin, the first created user has the UID of 1000. That means brew doesn't work for any user besides the first created one. I typically create two accounts on my personal system. The first is an account with administrator privileges, the second is a standard user account. I use the latter for my day to day tasks. 

I could adjust Brew to work with the user account with a UID of 1001 (which the second account on a Fedora system receives by default), but Homebrew is fundamentally broken due to this design limitation. I'd rather remove and disable it than try to workaround its poor design (I also think Homebrew in general is poorly designed). However, I acknowledge that other people may use it so I don't remove it if it's already installed and don't prevent users from installing it. 

Homebrew is setup on Bluefin using the `brew-setup.service` systemd module, which is enabled by default in Bluefin. Dinosaur OS disables it by default. You can setup Homebrew by starting or enabling this service.

The script /usr/libexec/remove-brew will remove Homebrew if it's already installed. This script effectively removes everything `brew-setup.service` creates. Therefore, `brew-setup.service` should be able to reinstall Homebrew if desired. 

One important caveat to note is that this image adds `--disable-module-brew` to the ExecStart line of `/usr/lib/systemd/system/uupd.service`, which disables the service from updating installed Homebrew packages. This is done because `uudp.service` will throw an error if Homebrew isn't installed unless the `--disable-module-brew` argument is present. This isn't undone if `brew-setup.service` is run, which means Homebrew packages won't be automatically updated on the system. The only easy way to enable automatic Homebrew updates on Dinosaur OS is to copy `/usr/lib/systemd/system/uupd.service` to `/etc/systemd/system/uupd.services` and remove `--disable-module-brew` from the ExecStart line.

# Other Changes

I hide the Discourse and Documentation launch icons. I don't use these so they're unwanted clutter in my launcher. I also hide the System Updater. It opens a terminal and runs `ujust update` and then closes the terminal. `ujust update` updates both the bootc image and installed flatpaks. `uupd.service` already does this periodically. Therefore, I don't use System Updated and it's also unwanted clutter for me.
