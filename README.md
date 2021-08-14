# vscode-termux
VS Code for Termux
## How to Install
```bash
make
apt install ./vscode-termux.deb
```
### Troubleshooting
If `code` failed to install, try to do this:
```bash
proot-distro login debian-vscode
apt install code
dpkg --configure -a
```
