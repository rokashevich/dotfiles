cat <<'EOF2' >/data/data/com.termux/files/usr/bin/c
while true;do
  temp_max=0
  for type_file in /sys/class/thermal/thermal_zone*/type;do
    type_data="$(cat "${type_file}")"
    [[ ! "${type_data}" =~ ^tsens_tz_sensor[0-9]+ ]] && continue
    temp_file="${type_file/type/temp}"
    temp_data="$(cat "${temp_file}")"
    (( ${temp_data} > ${temp_max} )) && temp_max=${temp_data}
  done
  temp_max=$(( ${temp_max} / 10 ))

  hdd_avail_bytes=$(stat -f /storage/emulated|grep 'Block'|tr '\n' ' '|awk '{print $3*$14}')

  mem_avail_bytes=$(free|grep Mem|awk '{print $7*1000}')

  load_avg1=$(cat /proc/loadavg|cut -d ' ' -f 1)

  uptime=$(cat /proc/uptime|cut -d ' ' -f 1)

  echo "➤ " \
    t=${temp_max} \
    hdd_avail_bytes=${hdd_avail_bytes} \
    mem_avail_bytes=${mem_avail_bytes} \
    load_avg1=${load_avg1} \
    uptime=${uptime}

  cat <<EOF | curl --data-binary @- http://192.168.1.19/pushgateway/metrics/job/manual/instance/redmi4-p
    # TYPE manual_temp_celcius gauge
    # HELP manual_temp_celcius Max temp celcius from all censors.
    manual_temp_celcius{component="max"} ${temp_max}

    # TYPE manual_filesystem_avail_bytes gauge
    # HELP manual_filesystem_avail_bytes HDD bytes available.
    manual_filesystem_avail_bytes{mounpoint="/storage/emulated"} ${hdd_avail_bytes}

    # TYPE manual_memory_avail_bytes gauge
    # HELP manual_memory_avail_bytes RAM bytes available.
    manual_memory_avail_bytes ${mem_avail_bytes}

    # TYPE manual_load_avg1 gauge
    # HELP manual_load_avg1 Load average 1 min.
    manual_load_avg1 ${load_avg1}

    # TYPE manual_uptime gauge
    # HELP manual_uptime Uptime seconds.
    manual_uptime ${uptime}
EOF
  sleep 60
done
EOF2
chmod +x /data/data/com.termux/files/usr/bin/c

cat <<'EOF' >/data/data/com.termux/files/usr/bin/t
pkill tmux

session="termux"
tmux start-server

tmux new-session -d -s ${session} -n service
tmux selectp -t ${session}:0
tmux send-keys "dropbear -F" C-m
tmux splitw -v -p 90
tmux send-keys "c" C-m

tmux new-window -t ${session}:1 -n work

tmux attach-session -t ${session}:0
tmux detach -a
EOF
chmod +x /data/data/com.termux/files/usr/bin/t
