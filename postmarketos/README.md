# Вход в Fastboot
1. power зажать до перезагрузки
2. voldn зажать при появлении белого экрана и держать до входа в fastboot
# Настройка окружения
```bash
pip install -U pmbootstrap

pmbootstrap shutdown
sudo rm -rf "`pmbootstrap config work`"
rm -f ~/.config/pmbootstrap.cfg
rm -f ~/.local/bin/pmbootstrap

pmbootstrap zap
pmbootstrap status
pmbootstrap pull

pmbootstrap init
# wpa_supplicant,avahi,curl,grep,sed,procps,tmux,iptables,nfs-utils,avahi
```
# Пересборка ядра
```bash
# qcom,mdss_dsi_r63350_1080p_video mido
pmbootstrap kconfig edit linux-postmarketos-qcom-msm8953
cd ~/dotfiles/postmarketos/linux-postmarketos-qcom-msm8953-6.4
cp -v ~/.local/var/pmbootstrap/chroot_native/home/pmos/build/src/linux-*/.config config-*
sed -i '/  config-postmarketos-qcom-msm8953.aarch64/d' APKBUILD
sed -i '$e sha512sum config-*' APKBUILD
cp -v * ~/.local/var/pmbootstrap/cache_git/pmaports/device/testing/linux-postmarketos-qcom-msm8953
cd ~/.local/var/pmbootstrap/cache_git/pmaports && git pull
pmbootstrap build --force linux-postmarketos-qcom-msm8953
```
# Прошивка
```bash
pmbootstrap flasher flash_lk2nd
sudo ~/android/platform-tools/fastboot reboot
sudo ~/android/platform-tools/fastboot flashing unlock

sudo ~/android/platform-tools/fastboot getvar current-slot
sudo ~/android/platform-tools/fastboot set_active a / b

sudo ~/android/platform-tools/fastboot format:ext4 boot
sudo ~/android/platform-tools/fastboot format:ext4 system
sudo ~/android/platform-tools/fastboot format:ext4 userdata

sudo ~/android/platform-tools/fastboot format:ext4 boot_a
sudo ~/android/platform-tools/fastboot format:ext4 boot_b
sudo ~/android/platform-tools/fastboot format:ext4 system_a
sudo ~/android/platform-tools/fastboot format:ext4 system_b
sudo ~/android/platform-tools/fastboot format:ext4 userdata

pmbootstrap install --add lk2nd-msm8953
pmbootstrap flasher flash_kernel
pmbootstrap flasher flash_rootfs --partition userdata
```
# Настройка после загрузки
```bash
ssh-keygen -f ~/.ssh/known_hosts -R "172.16.42.1"
ssh 172.16.42.1

# НАСТРОЙКА СЕТИ
# Ручная настройка:
# ifup lo
# wpa_supplicant -B -i wlan0 -c <(wpa_passphrase SSID 'PASSWORD')
# udhcpc -S -q -i wlan0
# Эту часть делается через my.start:
# cat <<'EOF' >/etc/network/interfaces
# auto lo
# iface lo inet loopback
# EOF
# rc-service wpa_supplicant start
# rc-service networking start
# ssid="r"
# psk=f734ca9ca54b40421aeb68196b0d894aadc15d92aded6da0d1ff95d66745e2e3
cat <<'EOF' >/etc/wpa_supplicant/wpa_supplicant.conf
network={
  ssid="r5"
  psk=6d1af35284b05c3649f8c09f0a7f6ab67229478b71333b0fcdebf4b0583294a1
}
EOF
cat <<'EOF' >/etc/network/interfaces
auto lo
iface lo inet loopback
EOF
cat <<'EOF' >/etc/local.d/my.start
nohup sh -c "/autorun.sh|logger" &>/dev/null </dev/null &
nohup sh -c "k3s agent --server https://192.168.1.19:6443 --token K107f7e3ddd56c89a1784341b0f297b2b7b81377235459255076f861f2cec85a151::server:256295e769763f4f428538f322fca057 2>&1|logger" &>/dev/null </dev/null &
EOF
chmod +x /etc/local.d/my.start

cat <<'EOF' >/autorun.sh
#!/bin/sh
sleep 60
echo "Set scaling governor."
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor

[ "`hostname`" == "mido" ] && {
  echo "Run mido specific tasks."
  echo 0 > /sys/class/graphics/fb0/blank
  echo 1 > /sys/class/graphics/fb0/blank
}

echo "Run main loop."
counter=0
while true
do
  ip -4 addr show|grep -q wlan0 || {
    echo "Set up wlan0."
    pkill -9 wpa_supplicant
    wpa_supplicant -B -i wlan0 -c /etc/wpa_supplicant/wpa_supplicant.conf
    udhcpc -S -qn -i wlan0
  }
  [ $((counter%1440)) = 0 ] && {
    echo "Sync ntp."
    ntpd -d -q -n -p uk.pool.ntp.org
  }
  s=`cat /sys/class/power_supply/qcom-smbchg-usb/online`
  [ "$s" == "0" ] && {
    echo "$(date +'%Y-%m-%d %H:%M:%S') poweroff!" >> /var/log/permanent.log
    pidof poweroff || poweroff -d 120 &
  } || {
    pkill poweroff;
  }
  echo "Sleep ${counter}."
  sleep 60
  counter=$((counter+1))
done
EOF
chmod +x /autorun.sh

cat | awk '{print $1}' >/etc/modules <<'EOF'
af_packet               CONFIG_PACKET +
ipv6                    CONFIG_IPV6   +
ipt_REJECT              CONFIG_IP_NF_TARGET_REJECT +
ip_tables               CONFIG_IP_NF_IPTABLES +
iptable_filter          CONFIG_IP_NF_FILTER +
vxlan                   CONFIG_VXLAN +
x_tables                CONFIG_NETFILTER_XTABLES +
xt_conntrack            CONFIG_NETFILTER_XT_MATCH_CONNTRACK +
xt_tcpudp               CONFIG_NETFILTER_XTABLES +
xt_addrtype             CONFIG_NETFILTER_XT_MATCH_ADDRTYPE +
xt_nat                  CONFIG_NETFILTER_XT_NAT
xt_comment              CONFIG_NETFILTER_XT_MATCH_COMMENT +
xt_MASQUERADE           CONFIG_NETFILTER_XT_TARGET_MASQUERADE +
xt_mark                 CONFIG_NETFILTER_XT_MARK +
nf_reject_ipv4          CONFIG_NF_REJECT* +
nfnetlink               CONFIG_NETFILTER_NETLINK
fuse                    CONFIG_FUSE_FS
ipt_MASQUERADE
iptable_nat             CONFIG_IP_NF_NAT
nf_nat                  CONFIG_NF_NAT
br_netfilter            CONFIG_BRIDGE_NETFILTER
overlay                 CONFIG_OF_OVERLAY
openvswitch             https://www.kernelconfig.io/CONFIG_OPENVSWITCH
ip_set                  https://www.kernelconfig.io/CONFIG_IP_SET
nft_compat              https://www.kernelconfig.io/CONFIG_NFT_COMPAT
xt_NFLOG                https://www.kernelconfig.io/CONFIG_NETFILTER_XT_TARGET_NFLOG
nf_conntrack_netlink    https://www.kernelconfig.io/CONFIG_NF_CT_NETLINK
xt_limit                https://www.kernelconfig.io/CONFIG_NETFILTER_XT_MATCH_LIMIT
xt_multiport            https://www.kernelconfig.io/CONFIG_NETFILTER_XT_MATCH_MULTIPORT
xt_physdev              https://www.kernelconfig.io/CONFIG_NETFILTER_XT_MATCH_PHYSDEV
xt_recent               https://www.kernelconfig.io/CONFIG_NETFILTER_XT_MATCH_RECENT
xt_statistic            https://www.kernelconfig.io/CONFIG_NETFILTER_XT_MATCH_STATISTIC
EOF
cat >> /etc/cgconfig.conf <<'EOF'
mount {
cpuacct = /cgroup/cpuacct;
memory = /cgroup/memory;
devices = /cgroup/devices;
freezer = /cgroup/freezer;
net_cls = /cgroup/net_cls;
blkio = /cgroup/blkio;
cpuset = /cgroup/cpuset;
cpu = /cgroup/cpu;
}
EOF
rc-update add dbus
rc-update add avahi-daemon
rc-update add cgroups
rc-update add networking
rc-update del wpa_supplicant
rc-update del kill-pbsplash

[ "`hostname`" = "mido" ] && {
  sed 's/^[^#]*ttyMSM0/#&/' -i /etc/inittab
  sed 's/^[^#]*tty[2-6]/#&/' -i /etc/inittab
}


mkdir /etc/dropbear
dropbearkey -t rsa -f /etc/dropbear/dropbear_rsa_host_key

curl -sfL https://get.k3s.io|sh -s - agent --server https://192.168.1.19:6443 --token K107f7e3ddd56c89a1784341b0f297b2b7b81377235459255076f861f2cec85a151::server:256295e769763f4f428538f322fca057
rc-update del k3s-agent
rc-service k3s-agent stop



```

curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -



twrp-3.7.0_9-0-tissot.img
