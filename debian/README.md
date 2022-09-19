# debian

```
wpa_supplicant -B -i INTERFACE -c <(wpa_passphrase SSID 'PASWORD!')
dhclient INTERFACE

$ cat /etc/apt/apt.conf
APT::Install-Recommends "0";
APT::Install-Suggests "0";

apt install \
  apt-file firefox-esr ffmpeg firmware-sof-signed fonts-ubuntu gdm3 gedit git gnome-bluetooth gnome-control-center gnome-power-manager gnome-session gnome-terminal gnome-tweaks gpg gvfs-backends gvfs-fuse libspa-0.2-bluetooth mpv nautilus network-manager python3-pip man-db ssh virtualbox-qt xz-utils

#pipewire-audio-client-libraries???
echo 'deb http://deb.debian.org/debian bullseye-backports main' >> /etc/apt/sources.list
apt install \
  tlp/bullseye-backports tlp-rdw/bullseye-backports linux-image-amd64/bullseye-backports linux-headers-amd64/bullseye-backports
 
# https://wiki.debian.org/PipeWire
touch /etc/pipewire/media-session.d/with-pulseaudio
cp /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* /etc/systemd/user/

# Upgrade to SID
echo deb https://mirror.yandex.ru/debian unstable main non-free contrib' >/etc/apt/sources.list
apt update && apt dist-upgrade
rm -rf /etc/pipewire # больше не нужен

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
systemctl disable ssh
systemctl disable rsyslog

# Cron
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l; done
systemctl disable cron.service anacron.service 

# Grub
Disable background image:
vi /etc/default/grub
GRUB_BACKGROUND=0
```
