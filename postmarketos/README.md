# Вход в Fastboot
- volup+power зажать до перезагрузки
- voldn зажать при появлении белого экрана и держать до входа в fastboot
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
# wpa_supplicant,avahi,curl,grep,sed,procps,tmux
```
# Пересборка ядра
```bash
pmbootstrap kconfig edit linux-postmarketos-qcom-msm8953

cd ~/.local/var/pmbootstrap/chroot_native/home/pmos/build/src/linux-*/
sudo cp ~/dotfiles/postmarketos/config X
tee ~/postmarketos/linux-postmarketos-qcom-msm8953/config-postmarketos-qcom-msm8953.aarch64 ~/dotfiles/postmarketos/config < X
sha512sum ~/postmarketos/linux-postmarketos-qcom-msm8953/config-postmarketos-qcom-msm8953.aarch64

pmbootstrap build --force linux-postmarketos-qcom-msm8953
```
# Прошивка
```bash
pmbootstrap install --add lk2nd-msm8953

sudo fastboot get_active
sudo fastboot set_active a / b
sudo fastboot reboot

pmbootstrap flasher flash_lk2nd

pmbootstrap flasher flash_kernel
pmbootstrap flasher flash_rootfs --partition userdata
```
# Настройка после загрузки
```bash
ssh-keygen -f ~/.ssh/known_hosts -R "172.16.42.1"
ssh 172.16.42.1

cat <<'EOF' >/etc/network/interfaces
auto lo
iface lo inet loopback
EOF

cat <<'EOF' >/etc/local.d/my.start
#!/bin/sh
ifup lo
wpa_supplicant -B -i wlan0 -c <(wpa_passphrase SSID 'PASSWORD')
udhcpc -i wlan0
echo powersave | tee /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
nohup /bin/sh -c '\
  while true; \
    do \
        s=`cat /sys/class/power_supply/qcom-battery/status`; \
        [ "$s" == "Discharging" ] && { pidof poweroff || poweroff -d 120 & } || killall -q poweroff;
        sleep 120; \
    done' &>/dev/null &
EOF
chmod +x /etc/local.d/my.start

rc-update add crond && rc-service crond start
cat <<'EOF' >/etc/periodic/15min/ntp.sh
ntpd -d -q -n -p uk.pool.ntp.org
EOF
chmod +x /etc/periodic/15min/ntp.sh

cat <<'EOF' >/etc/modules
af_packet
ipv6
af_packet
ipv6
vxlan
x_tables
xt_conntrack
iptable_filter
nft_compat
xt_multiport
xt_NFLOG
xt_tcpudp
xt_addrtype
xt_physdev
xt_nat
xt_comment
ipt_REJECT
ip_tables
xt_limit
xt_MASQUERADE
xt_mark
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

rc-update add cgroups && rc-service cgroups start
apk add avahi && rc-update add avahi-daemon && rc-service avahi-daemon start

ssh a1.local 'cat > .bashrc' <<'EOF'
export PROMPT_COMMAND='printf "\033]0;%s\033\\" "${HOSTNAME%%.*}"'
EOF
```
# Проблемы
```
E0412 17:01:10.670259    6197 kubelet_network_linux.go:117] "Failed to ensure rule to drop invalid localhost packets in filter table KUBE-FIREWALL chain" err=<
        error appending rule: exit status 4: Ignoring deprecated --wait-interval option.
        Warning: Extension comment revision 0 not supported, missing kernel module?
        Warning: Extension conntrack revision 0 not supported, missing kernel module?
        iptables v1.8.8 (nf_tables):  RULE_APPEND failed (No such file or directory): rule in chain KUBE-FIREWALL
 >
 ```

 curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -



