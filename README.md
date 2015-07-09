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
