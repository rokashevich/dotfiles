# debian

```
wpa_supplicant -B -i INTERFACE -c <(wpa_passphrase SSID 'PASWORD!')
dhclient INTERFACE
echo 'deb http://deb.debian.org/debian bullseye-backports main' >> /etc/apt/sources.list
apt install --no-install-recommends \
  network-manager gdm3 gnome-session gnome-settings-daemon gnome-terminal nautilus gnome-tweaks \
  gvfs-backends gvfs-fuse gnome-control-center gnome-power-manager mpv pipewire-audio-client-libraries \
  alsa-utils gedit gstreamer1.0-pulseaudio evince libasound2-plugins libpulsedsp pulseaudio \
  pulseaudio-module-bluetooth pulseaudio-utils gnome-font-viewer fonts-ubuntu apt-file mc \
  tlp/bullseye-backports tlp-rdw/bullseye-backports curl xz-utils unzip python3-pip git gcc g++ \
  fonts-noto-color-emoji
```
