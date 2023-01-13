# debian 11
## Установка
### Временный wifi в консоли после устновки
```
wpa_supplicant -B -i INTERFACE -c <(wpa_passphrase SSID 'PASWORD!')
dhclient INTERFACE
```
### Установка основных пакетов
```
$ cat /etc/apt/apt.conf
APT::Install-Recommends "0";
APT::Install-Suggests "0";

$ apt install \
  apt-file firmware-sof-signed git gpg man-db xz-utils \
  fonts-ubuntu gdm3 gedit gnome-bluetooth gnome-control-center \
  gnome-power-manager gnome-session gnome-terminal gnome-tweaks \
  gvfs-backends gvfs-fuse nautilus network-manager linux-image-amd6 \
  linux-headers-amd64 \
  libspa-0.2-bluetooth pipewire-audio-client-libraries \
  ffmpeg python3-pip \
  firefox-esr mpv remmina-plugin-vnc remmina-plugin-rdp \
  cmake clang clang-format make ninja-build gdb \
  libgles-dev libxext-dev libboost-dev libboost-thread-dev
```
### Обновление некоторых пакетов из backports
```
echo 'deb http://deb.debian.org/debian bullseye-backports main' >> /etc/apt/sources.list
apt install -t bullseye-backports tlp tlp-rdw linux-image-amd64 linux-headers-amd64
```
### Настройка звука (всё равно не всё гладко с JBL)
```
bluetoothctl trust 78:44:05:68:2C:0C
# https://wiki.debian.org/PipeWire
apt install -t bullseye-backports pipewire pipewire-pulse wireplumber
touch /etc/pipewire/media-session.d/with-pulseaudio
cp /usr/share/doc/pipewire/examples/systemd/user/pipewire-pulse.* /etc/systemd/user/
```
### PyPI
```
pip install youtube-dl
```
### Docker
Лучше по актуальной инструкции - https://docs.docker.com/engine/install/debian
```
rm -rf /var/lib/docker /var/lib/containerd # при удалении
```
### Оптимизации
#### Gnome
```
gsettings set org.gnome.desktop.sound event-sounds false # disable system beep
```
#### Systemd
```
systemctl list-unit-files
systemctl disable rsyslog
```
#### Cron
```
for user in $(cut -f1 -d: /etc/passwd); do crontab -u $user -l; done
systemctl disable cron.service anacron.service

```

## Генерация списка установленных файлов
```
dpkg -l|awk '{print $2}'|sort > all_packages.txt
```
# tw89
Драйвер https://packages.debian.org/ru/sid/all/firmware-realtek/download
```
$ cat /etc/rc.local 
#!/bin/bash
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase r 'PASSWORD')
sleep 10
dhclient wlan0
$ systemctl start rc-local
$ apt install openssh-server tmux apt-file vbetool man-db lm-sensors strace hwinfo fbi mc btrfs-progs
$ echo "1" > /sys/class/graphics/fb0/blank
$ systemctl edit getty@tty1
[Service]
ExecStart=
ExecStart=-/sbin/agetty --autologin root --noclear %I 38400 linux
$ systemctl enable getty@tty1.service
$ dpkg-reconfigure locales
$ dpkg-reconfigure -plow console-setup
$ mkfs.btrfs -L data -f /dev/mmcblk1p1
$ cat /etc/fstab
...
/dev/mmcblk1p1  /data btrfs  defaults,compress-force=zstd:15  0  0
...
```
