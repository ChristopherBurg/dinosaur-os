# Dinosaur OS

This is my customized version of Bluefin.

I'm trying to keep the changes to a minimum. The main thing I do is add libvirt. I also remove several packages that I don't use or want.

# Packages Installed

libvirt and qemu are installed. These packages are available in Bluefin Developer Experience. However, rebased to bluefin-dx brings a lot of additional packages such as Docker and Visual Studio Code that I don't use. Rather than install a bunch of utilities I don't use just to get libvirt, I created this bootc image.

# Packages Removed

I remove a number of packages that Bluefin adds on top of Silverblue. fuse-encfs isn't actively maintained according to the [repository](https://github.com/vgough/encfs). I also have no use for it.

I pull out gnome-tweaks since I don't use any of its features. I also remove many of the gnome-shell-extension packages. I install my extensions in user space via the Extension Manager flatpak.

I remove ublue-brew because I found brew janky when I ran macOS and haven't seen anything to change my feelings since then. There are better options on Linux.

# Other Changes

I hide the Discourse and Documentation launch icons. I don't use these so they're unwanted clutter in my laucher.
