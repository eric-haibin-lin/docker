#!/bin/bash

NUMPROC=$1
HOSTLINE=$2

time /opt/amazon/openmpi/bin/mpirun \
	-x LD_LIBRARY_PATH=/opt/amazon/efa/lib:/opt/amazon/openmpi/lib:/usr/local/cuda/lib64 \
    -x FI_PROVIDER="efa" \
    -x FI_EFA_TX_MIN_CREDITS=64 \
    -x NCCL_DEBUG=INFO \
    -x NCCL_TREE_THRESHOLD=0 \
    --mca btl tcp,self \
    --mca btl_tcp_if_exclude lo,docker0 \
    --bind-to none \
    -H $HOSTLINE \
    -np $NUMPROC \
    /opt/build/nccl-tests/build/all_reduce_perf -b 640M -e 640M -t 1 -f 2 -g 1 -c 1 -n 100  2>&1 | tee --append nccl_test.log

