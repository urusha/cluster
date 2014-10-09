#!/bin/sh

VMHOSTSCORE="20"
VMPATH="/srv/libvirt/qemu"

###
VMNAME="$1"
VMHOST="$2"

[ -z "$VMNAME" ] || [ -z "$VMHOST" ] && { echo "Usage: `basename $0` domain host"; exit 1; }
[ -f "$VMPATH/$VMNAME.xml" ] || { echo "$VMPATH/$VMNAME.xml doesn't exist"; exit 1; }
crm_mon -1n | grep -q "^Node $VMHOST " || { echo "Host '$VMHOST' doesn't exist in the cluster"; exit 1; }

###

pcs resource create "kvm_$VMNAME" ocf:heartbeat:VirtualDomain config="$VMPATH/$VMNAME.xml" \
	migration_transport=ssh autoset_utilization_cpu=true autoset_utilization_hv_memory=true meta allow-migrate=true \
	op start timeout=30 op stop timeout=120 migrate_to timeout=120 op migrate_from timeout=120 &&
    pcs constraint order libvirtd-clone then "kvm_$VMNAME" &&
    pcs constraint location "kvm_$VMNAME" prefers "$VMHOST=$VMHOSTSCORE" || { echo "Error while creating domain"; exit 1; }
