#!/bin/bash

# The external agent is fed with environment variables allowing us to know
# what transition happened and to react accordingly:
# http://clusterlabs.org/doc/en-US/Pacemaker/1.1-crmsh/html/Pacemaker_Explained/s-notification-external.html
# Generates SMTP alerts for any failing monitor operation
# OR
# for any operations (even successful) that are not a monitor.
# It collects notifications for 20 seconds and then sends them all in a single message.

_addmsg() {
if [[ ${CRM_notify_rc} != 0 && ${CRM_notify_task} == "monitor" ]] || [[ ${CRM_notify_task} != "monitor" ]] ; then
echo "Node: ${CRM_notify_node}
Resource: ${CRM_notify_rsc}
Operation: ${CRM_notify_task}
Description: ${CRM_notify_desc}
Status: ${CRM_notify_status}
ReturnCode: ${CRM_notify_rc}
NotificationTargetReturnCode: ${CRM_notify_target_rc}
" >> /tmp/pcmk_smtp_helper.msg
fi
}

_do() {
echo "Pacemaker Notification
----------------------
" > /tmp/pcmk_smtp_helper.msg
_addmsg
sleep 20
cat /tmp/pcmk_smtp_helper.msg | mail -s "ClusterMon Notification" ${CRM_notify_recipient} && rm -f /tmp/pcmk_smtp_helper.msg && exit 0 || exit 1
}

(
if flock -n 200; then
    _do
else
    _addmsg
    exit 0
fi
) 200>/tmp/pcmk_smtp_helper.lock

exit 0
