#!/bin/bash
#
# This script is called on container startup.
#

CLUSTERUSER=cluster

echo "Starting container services..."

if [ ! -d /run/sshd ]; then
    echo "Creating /run/sshd"
    mkdir -p /run/sshd
fi

echo "Starting SSHD."
/usr/sbin/sshd -f /home/$CLUSTERUSER/.ssh/sshd_config

sleep infinity

