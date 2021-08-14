# vscode-termux
A Debian package that allows you to use Visual Studio Code in Termux, inspired by firefox-termux by @WMCB-Tech
## How to Install
```bash
make
apt install ./vscode-termux.deb
```
## Troubleshooting
If `code` failed to install, try to do this:
```bash
proot-distro login debian-vscode
apt install code
dpkg --configure -a
```
