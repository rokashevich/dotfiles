# debian

```
wpa_supplicant -B -i INTERFACE -c <(wpa_passphrase SSID 'PASWORD!')
dhclient INTERFACE
echo 'deb http://deb.debian.org/debian bullseye-backports main' >> /etc/apt/sources.list
apt install --no-install-recommends \
  network-manager gdm3 gnome-session gnome-settings-daemon tilix nautilus gnome-tweaks \
  gvfs-backends gvfs-fuse gnome-control-center gnome-power-manager mpv \
  alsa-utils gedit gstreamer1.0-pulseaudio evince libasound2-plugins libpulsedsp pulseaudio \
  libcanberra-pulse `#gnome settings to work` \
  gnome-bluetooth bluez bluez-tools gnome-font-viewer fonts-ubuntu apt-file mc tilix \
  tlp/bullseye-backports tlp-rdw/bullseye-backports curl xz-utils unzip python3-pip git remmina remmina-plugin-vnc remmina-plugin-rdp \
  pkg-config strace gcc g++ cmake clang-format ninja-build `#dev` \
  libegl-dev libgles-dev libwayland-dev libxext-dev `#opengl` \
  fonts-noto-color-emoji python3-virtualenv qbittorrent \
  ca-certificates curl gnupg lsb-release `#docker prerequisites` \
  sshpass \
  libboost-all-dev `#temp` \
  firefox-esr `# echo 'export MOZ_ENABLE_WAYLAND=1' >> ~/.profile; check: about:support, ctrl+f "Window Protocol"`

# PyPI
pip install youtube-dl

# Docker https://docs.docker.com/engine/install/debian
apt install --no-install-recommends docker-ce docker-ce-cli containerd.io
systemctl disable docker containerd
systemctl stop docker containerd
systemctl start docker containerd
# Uninstall
rm -rf /var/lib/docker /var/lib/containerd

# Gnome
gsettings set org.gnome.desktop.sound event-sounds false # disable system beep

# Systemd
systemctl list-unit-files
systemctl disable wpa_supplicant.service
systemctl disable systemd-timesyncd.service
systemctl disable rsyslog.service syslog.socket

# Cron
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l; done
systemctl disable cron.service anacron.service 
```
