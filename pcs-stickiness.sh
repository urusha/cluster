#!/bin/sh

# timeout
TIMEOUT="60"
# resource-stickiness
RS="100"

if [ "$1" = "-f" ]; then
    RSF="YES"
    shift
else
    RSF="NO"
fi

if echo "$1" | grep -q '^[0-9]\+$' && [ "$1" -gt 0 ]; then
    TIMEOUT="$1"
elif [ -n "$1" ]; then
    echo "Usage: `basename $0` [-f] [timeout]"
    exit 1
fi

if [ "$RSF" != "YES" ] && crm_mon -1n | grep -qE ':[[:space:]]+(offline|Stopped|Failed)[[:space:]]*$'; then
    echo "Cluster has offline node or stopped/failed resources/actions. Exiting"
    exit 1
fi

pcs resource defaults resource-stickiness="0"
sleep "$TIMEOUT"
pcs resource defaults resource-stickiness="$RS"
