#!/bin/sh

# Move resource with cleaning its status up
# and clearing its temporary location constraints.

# Version: 20150924

[ -z "$1" ] && echo "Usage: `basename $0` resource [node]" >&2 && exit 1

if [ "`crm_mon -1n | grep 'Node .*: online$' | wc -l`" -lt 2 ]; then
    echo "No node to migrate to. Exiting..."
    exit 1
fi

if [ -n "$2" ] && crm_mon -1n | grep -q "Node $2: online$"; then
    echo "Node '$2' is not online. Exiting..."
    exit 1
fi

pcs resource cleanup "$1" || exit 1
echo -n "Clearing '$1' before move..."
pcs resource clear "$1"
sleep 1
echo

if [ -z "$2" ]; then
    echo -n "Moving '$1'..."
    pcs resource move "$1"
else
    echo -n "Moving '$1' to '$2' ..."
    pcs resource move "$1" "$2"
fi
sleep 3
echo

pcs resource clear "$1"
echo -n "Clearing '$1' after move..."
sleep 1
echo
