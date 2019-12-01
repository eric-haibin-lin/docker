#!/bin/bash
CONTAINERNAME=$1
CLUSTERUSER=$2
ECRPATH=haibinlin/bert-docker:test

docker kill $CONTAINERNAME

nvidia-docker run \
    --shm-size=32g \
    --rm \
    --name $CONTAINERNAME \
    --net=host --uts=host --ipc=host \
    --ulimit stack=67108864 --ulimit memlock=-1 \
    --ulimit nofile=9000:9000 \
    --security-opt seccomp=unconfined \
    -v /home/ec2-user/mxnet-data:/home/$CLUSTERUSER/mxnet-data \
    -e FI_PROVIDER=\"efa\" \
    --device=/dev/infiniband/uverbs0 \
    --detach \
    -e NVIDIA_VISIBLE_DEVICES=0,1,2,3,4,5,6,7 \
    $ECRPATH

echo "Container started!"
