cluster
=======

Pacemaker stuff

* fence_energenie - fence agent for EnerGenie EG-PDU-001 and similar. 7.0 release
* fence_energenie_7.1 - fence agent for EnerGenie EG-PDU-001 and similar. 7.1 release
* pcmk_smtp_helper.sh - ocf:pacemaker:ClusterMon smtp helper
* pcs-move.sh - script moves resource with cleaning its status up and clearing its temporary location constraints.
* pcs-stickiness.sh - script sets resource-stickiness to zero and after timeout sets it back to higher value, allowing resources to move due to location constraints.
* pcs-vm-add.sh - script creates kvm-domain resource, order and location constraints
* pcs-drbd-verify.sh - script verifies drbd resources and restarts pacemaker if required
* pcs-vm-setmem.sh - script sets current memory of all domains to maximum or default value, according to domain xml
* VirtualDomain.patch - patch makes VirtualDomain resource agent understand "migration_unsafe" attribute, which allows to do unsafe live migration of domains. This is needed because: 1) generally it's only safe to use cache='writethrough' with QEMU domains and DRBD (see http://forum.proxmox.com/threads/18259-KVM-on-top-of-DRBD-and-out-of-sync-long-term-investigation-results ); 2) live migration of domain with cache='writethrough' requires using 'virsh migrate' with '--unsafe' argument. Don't worry, it's completely safe to use 'unsafe' live migration with DRBD protocol-C and cache='writethrough'.
