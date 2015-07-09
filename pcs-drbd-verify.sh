#!/bin/sh

export LANG=C

if crm_mon -1n | grep -qi ': offline'; then
    echo "Cluster has offline node(s). Exiting"
    exit 1
fi

VERIFYDATE=`date +"%Y-%m-%d %H:%M:%S"`
drbdadm verify all
sleep 2

while : ; do
    grep -q 'Verify' /proc/drbd || break
    sleep 10
done

if journalctl --since="$VERIFYDATE" | grep "Online verify found"; then
    echo "DRBD resync required. Restarting pacemaker..."
else
    exit 0
fi

systemctl stop pacemaker
sleep 1
systemctl start pacemaker

echo "Pacemaker restarted"
