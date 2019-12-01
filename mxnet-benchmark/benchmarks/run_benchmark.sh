#!/bin/bash
set -ex

HOMEDIR=/home/cluster
HOSTFILE=$HOMEDIR/mpihosts.txt
TESTNAME=$1
HOSTPARAMS=$2

export PATH="/usr/local/cuda/bin:/opt/amazon/openmpi/bin:$PATH"

if [ -z "$TESTNAME" ]; then
    echo "Usage: $0 <mnist|bert|nccl>"
    exit
fi

# first make sure we have a hostfile that lists all hosts we want to run the benchmark on
if [ ! -z "$HOSTPARAMS" ]; then
	echo "$HOSTPARAMS" > $HOSTFILE
	sed -i 's/,/\n/g' $HOSTFILE
	sed -i 's/:8$//g' $HOSTFILE
else
	if [ ! -f $HOSTFILE ]; then
    	echo "ERROR: $HOSTFILE file not found, exiting."
    	exit
	fi
fi

HOSTLINE=""
NUMHOSTS=0
for host in $(cat $HOSTFILE | awk '{print $1}'); do
    if [ -z "$HOSTLINE" ]; then
        HOSTLINE="$host:8"
    else
        HOSTLINE="$HOSTLINE,$host:8"
    fi
    NUMHOSTS=$(expr $NUMHOSTS + 1)
done

NUMPROC=$(expr $NUMHOSTS \* 8)

if [ "$TESTNAME" == "mnist" ]; then
    echo "Running mnist benchmark test on $NUMHOSTS hosts."
    echo "Numproc: $NUMPROC"
    horovodrun -np $NUMPROC -H $HOSTLINE python3 /opt/benchmarks/mnist/mxnet_mnist.py --epochs 10
elif [ "$TESTNAME" == "bert" ]; then
    echo "Running bert training test on $NUMHOSTS hosts (NUMPROC=$NUMPROC, HOSTS=$HOSTLINE)."
    NP=$NUMPROC /opt/benchmarks/bert.sh $NUMPROC $HOSTLINE
elif [ "$TESTNAME" == "nccl" ]; then
    echo "Running nccl-tests on $NUMHOSTS hosts."
    /opt/benchmarks/nccl_tests.sh $NUMPROC $HOSTLINE
else
    echo "Unknown test $TESTNAME, bailing."
fi
