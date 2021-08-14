##
## Plug-in for installing Debian Unstable (Sid).
##

DISTRO_NAME="Visual Studio Code Termux (Debian Unstable/Sid)"

# Rootfs is in subdirectory.
DISTRO_TARBALL_STRIP_OPT=0

# You can override a CPU architecture to let distribution
# be executed by QEMU (user-mode).
#
# You can specify the following values here:
#
#  * aarch64: AArch64 (ARM64, 64bit ARM)
#  * armv7l:  ARM (32bit)
#  * i686:    x86 (32bit)
#  * x86_64:  x86 (64bit)
#
# Default value is set by proot-distro script and is equal
# to the CPU architecture of your device (uname -m).
#DISTRO_ARCH=$(uname -m)

# Returns download URL and SHA-256 of file in this format:
# SHA-256|FILE-NAME
get_download_url() {
	local deb_arch
	local sha256

	case "$DISTRO_ARCH" in
		aarch64)
			deb_arch="arm64v8"
			;;
		armv7l|armv8l)
			deb_arch="arm32v7"
			;;
		i686)
			deb_arch="i386"
			;;
		x86_64)
			deb_arch="amd64"
			;;
	esac
	#sha256="$(curl -L https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-${deb_arch}/sid/rootfs.tar.xz.sha256)"

	echo "https://github.com/debuerreotype/docker-debian-artifacts/raw/dist-${deb_arch}/sid/rootfs.tar.xz"
}

# Define here additional steps which should be executed
# for configuration.
distro_setup() {
	# Hint: $PWD is the distribution rootfs directory.
	#echo "hello world" > ./etc/motd

	# Run command within proot'ed environment with
	# run_proot_cmd function.
	# Uncomment this to do system upgrade during installation.
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
	#run_proot_cmd apt upgrade -yq
	:
}
