# This is a default distribution plug-in.
# Do not modify this file as your changes will be overwritten on next update.
# If you want customize installation, please make a copy.
DISTRO_NAME="Visual Studio Code Termux (Debian Bullseye)"

TARBALL_URL['aarch64']="https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-aarch64-pd-v2.2.0.tar.xz"
TARBALL_SHA256['aarch64']="162ec58dd3cfd4e8924ad64e9d9fa4ee0b4ea7ddcfb62a0f6c542c6e6079b0fd"
TARBALL_URL['arm']="https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-arm-pd-v2.2.0.tar.xz"
TARBALL_SHA256['arm']="4d907f0b596b5040fbf0fa41c9da5eea9049ff64bf2f54ddbd3ab0e317b16aa9"
TARBALL_URL['i686']="https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-i686-pd-v2.2.0.tar.xz"
TARBALL_SHA256['i686']="357fcdd86b1680ce65bd43b2d8a127277f513ec1464ae70fbffe53a8952c6b03"
TARBALL_URL['x86_64']="https://github.com/termux/proot-distro/releases/download/v2.2.0/debian-x86_64-pd-v2.2.0.tar.xz"
TARBALL_SHA256['x86_64']="5ce7f65e089831b37d1cddeb67cfe4f3c487a507226b90535f420e13a37b9434"

distro_setup() {
	echo 'deb http://deb.debian.org/debian sid main contrib non-free' > ./etc/apt/sources.list
	run_proot_cmd apt update
	run_proot_cmd apt install ca-certificates apt-transport-https -yq
	wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > ./root/packages.microsoft.gpg
	run_proot_cmd install -o root -g root -m 644 /root/packages.microsoft.gpg /etc/apt/trusted.gpg.d/
	echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/trusted.gpg.d/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" > ./etc/apt/sources.list.d/vscode.list
	rm -f ./root/packages.microsoft.gpg
	run_proot_cmd apt update
	# Fix dbus not installing
	touch ./var/lib/dpkg/statoverride
	run_proot_cmd apt install code alsa-utils pulseaudio libxshmfence1 -y
	# Make ALSA to use PulseAudio (this might be unnessesary since Visual Studio Code doesn't use sounds)
	mkdir ./usr/share/alsa/alsa.conf.pulse/
	run_proot_cmd dpkg-divert --divert /usr/share/alsa/alsa.conf.pulse/pulse.conf --rename  /usr/share/alsa/alsa.conf.d/pulse.conf
	run_proot_cmd dpkg-divert --divert /usr/share/alsa/alsa.conf.pulse/99-pulseaudio-default.conf.example  --rename  /usr/share/alsa/alsa.conf.d/99-pulseaudio-default.conf.example
	run_proot_cmd dpkg-divert --divert /usr/share/alsa/alsa.conf.pulse/50-pulseaudio.conf --rename  /usr/share/alsa/alsa.conf.d/50-pulseaudio.conf
	run_proot_cmd useradd -d /data/data/com.termux/files/home vscode
	# Replace `ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" "$@"` with "$ELECTRON" "$@" to fix VS Code doesn't run
	sed -i 's:ELECTRON_RUN_AS_NODE=1 "$ELECTRON" "$CLI" "$@":"$ELECTRON" "$@":g' ./usr/share/code/bin/code
}
