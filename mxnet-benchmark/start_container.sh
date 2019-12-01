#!/bin/bash

set -ex
CONTAINERNAME=$1
IMAGENAME=$2
KEYFILE="ssh_cluster_key.pem"
CLUSTERUSER=cluster

nvidia-docker run \
    --shm-size=5g \
    --rm \
    --name $CONTAINERNAME \
    --net=host --uts=host --ipc=host \
    --ulimit stack=67108864 --ulimit memlock=-1 \
    --ulimit nofile=9000:9000 \
    --security-opt seccomp=unconfined \
    -e FI_PROVIDER=\"efa\" \
    --device=/dev/infiniband/uverbs0 \
    --detach \
    $IMAGENAME

echo "Container started!"

sleep 5

if [ -e $KEYFILE ]; then
    echo "Removing existing host key $KEYFILE"
    rm -f $KEYFILE
fi

echo "Copying SSH private key from container to run tests.."
docker cp $CONTAINERNAME:/home/$CLUSTERUSER/.ssh/ssh_host_rsa_key $KEYFILE



