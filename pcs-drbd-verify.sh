#!/bin/sh

# Verify DRBD resources and restart pacemaker if required

# Version: 20150924

export LANG=C

if crm_mon -1n | grep -qE ':[[:space:]]+(OFFLINE(| \(standby\))|standby|Stopped|Failed)[[:space:]]*$'; then
    echo "Cluster has offline/standby node or stopped/failed resources/actions. Exiting"
    exit 1
fi

VERIFYDATE=`date +"%Y-%m-%d %H:%M:%S"`
drbdadm verify all
sleep 2

while : ; do
    grep -q 'Verify' /proc/drbd || break
    sleep 10
done

if ! journalctl --since="$VERIFYDATE" | grep "Online verify found"; then
    exit 0
fi

echo "DRBD resync required."

# Set VMs current memory to default values
if [ -x "`dirname "$0"`/pcs-vm-setmem.sh" ]; then
    echo "Setting VMs current memory to default values..."
    "`dirname "$0"`/pcs-vm-setmem.sh" -d
    sleep 60
fi

# Restart pacemkaer
echo "Restarting pacemaker..."
systemctl stop pacemaker
sleep 1
systemctl start pacemaker

echo "Finished."
