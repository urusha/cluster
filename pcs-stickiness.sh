#!/bin/sh

# timeout
TIMEOUT="120"
# resource-stickiness
RS="100"

if echo "$1" | grep -q '^[0-9]\+$' && [ "$1" -gt 0 ]; then
    TIMEOUT="$1"
elif [ -n "$1" ]; then
    echo "Usage: `basename $0` [timeout]"
    exit 1
fi

if pcs status | grep -q 'Stopped'; then
    echo "Cluster has 'Stopped' resources. Exiting..."
    exit 1
else
    pcs resource defaults resource-stickiness="0"
    sleep "$TIMEOUT"
    pcs resource defaults resource-stickiness="$RS"
fi
