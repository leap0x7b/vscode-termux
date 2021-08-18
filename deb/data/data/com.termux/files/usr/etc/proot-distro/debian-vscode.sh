# This is a default distribution plug-in.
# Do not modify this file as your changes will be overwritten on next update.
# If you want customize installation, please make a copy.
DISTRO_NAME="Visual Studio Code Termux (Debian Unstable/Sid)"

TARBALL_URL['aarch64']="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-arm64v8/sid/rootfs.tar.xz"
TARBALL_URL['arm']="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-arm32v7/sid/rootfs.tar.xz"
TARBALL_URL['i686']="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-i386/sid/rootfs.tar.xz"
TARBALL_URL['x86_64']="https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-amd64/sid/rootfs.tar.xz"

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
