#!/bin/bash

echo "Fetching the details..."

count=0

echo "servers:" > servers.yaml

for vm in $(VBoxManage list runningvms | awk '{print $1}' | tr -d '"'); do
  IP=$(VBoxManage guestproperty get "$vm" "/VirtualBox/GuestInfo/Net/1/V4/IP" | awk '{print $2}')
  HN=$(VBoxManage guestproperty get "$vm" "/VirtualBox/GuestInfo/Net/1/V4/HN" | awk '{print $2}')

  cat >> servers.yaml <<EOF
  - hostname: $vm
    ip: $IP
EOF

  count=$((count+1))

done

echo "🖥 Total Servers running: $count ✅"
cat servers.yaml
