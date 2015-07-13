#!/bin/sh

# Set VMs memory to:
# * <memory> value from domain's xml by default;
# * <currentMemory> value from domain's xml, if there is offline node or if "-d" provided as argument.

export LANG=C

if crm_mon -1n | grep -qE ':[[:space:]]+(Stopped|Failed)[[:space:]]*$'; then
    echo "Cluster has stopped/failed resources/actions. Exiting"
    exit 1
fi

if crm_mon -1n | grep -qi ': offline' || [ "$1" = '-d' ]; then
    SETMEM='def'
else
    SETMEM='max'
fi

DOMRESS=`crm_mon -1 | grep 'ocf::heartbeat:VirtualDomain' | awk '{print $1}'`

for DOMRES in ${DOMRESS}; do
    DOMXML="`pcs resource show "$DOMRES" | sed -n 's,^.*config=\([^[[:space:]]\+\)[[:space:]].*$,\1,p'`"
    DOMNODE="`crm_mon -1 | awk '$1=="'"$DOMRES"'" {print $4}'`"
    DOMNAME="`sed -n 's/^.*<name>\([^<]\+\)<.*$/\1/p' "$DOMXML"`"
    DOMMEMCUR="`virsh -c "qemu+ssh://$DOMNODE/system" dominfo "$DOMNAME" | awk '$0~/^Used memory:/ {print $3}'`"
    DOMMEMDEF="`sed -n 's/^.*<currentMemory.*>\([0-9]\+\)<.*$/\1/p' "$DOMXML"`"
    DOMMEMMAX="`sed -n 's/^.*<memory.*>\([0-9]\+\)<.*$/\1/p' "$DOMXML"`"

    if [ "$SETMEM" = 'def' ]; then
	DOMMEMSET="$DOMMEMDEF"
    else
	DOMMEMSET="$DOMMEMMAX"
    fi

    if [ "$DOMMEMCUR" -ne "$DOMMEMSET" ]; then
	virsh -c "qemu+ssh://$DOMNODE/system" setmem "$DOMNAME" "$DOMMEMSET" --live > /dev/null
    fi
done
