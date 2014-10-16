#!/bin/sh

VMNODESCORE="20"
VMPATH="/srv/libvirt/qemu"
VMOPT="migration_transport=ssh  meta allow-migrate=true \
    autoset_utilization_cpu=true autoset_utilization_hv_memory=true \
    op start timeout=30 op stop timeout=120 op migrate_to timeout=120 op migrate_from timeout=120"

###

VMNAME="$1"
VMNODE="$2"

[ -z "$VMNAME" ] || [ -z "$VMNODE" ] && { echo "Usage: `basename $0` domain node"; exit 1; }
[ -f "$VMPATH/$VMNAME.xml" ] || { echo "$VMPATH/$VMNAME.xml doesn't exist"; exit 1; }
crm_mon -1n | grep -q "^Node $VMNODE " || { echo "Node '$VMNODE' doesn't exist in the cluster"; exit 1; }

###

pcs resource create "kvm_$VMNAME" ocf:heartbeat:VirtualDomain config="$VMPATH/$VMNAME.xml" $VMOPT &&
    pcs constraint order libvirtd-clone then "kvm_$VMNAME" &&
    pcs constraint location "kvm_$VMNAME" prefers "$VMNODE=$VMNODESCORE" ||
    { echo "Error while creating domain '$VMNAME'"; exit 1; }
