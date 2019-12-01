#!/bin/bash

# This script launches the following training jobs
# 1) BERT pre-train phase 1 (with seq-len = 128)
# 2) BERT pre-train phase 2 (with seq-len = 512). This requires the checkpoint from (1)
# 3) BERT fine-tune on SQuAD. This requires the checkpoint from (2).
export DATA_HOME=~/mxnet-data/bert-pretraining/datasets

export DEBUG="${DEBUG:-1}"
export HOSTFILE="${HOSTFILE:-mpihosts.txt}"
export NP="${NP:-8}"
export CKPTDIR="${CKPTDIR:-./test-ckpt}"
export OPTIMIZER="${OPTIMIZER:-lamb3}"
#export OPTIMIZER="${OPTIMIZER:-bertadam}"
export DATA="${DATA:-$DATA_HOME/book-corpus/book-corpus-large-split/*.train,$DATA_HOME/enwiki/enwiki-feb-doc-split/*.train}"
export DATAEVAL="${DATAEVAL:-$DATA_HOME/book-corpus/book-corpus-large-split/*.dev,$DATA_HOME/enwiki/enwiki-feb-doc-split/*.dev}"
export DATAPHASE2="${DATAPHASE2:-$DATA_HOME/book-corpus/book-corpus-large-split/*.train,$DATA_HOME/enwiki/enwiki-feb-doc-split/*.train}"
export NO_SHARD="${NO_SHARD:-0}"
export RAW="${RAW:-1}"
export EVALRAW="${EVALRAW:-0}"
export NUM_DATA_THREAD="${NUM_DATA_THREAD:-8}"
export SCALE_NORM="${SCALE_NORM:-1}"
export SKIP_GLOBAL_CLIP="${SKIP_GLOBAL_CLIP:-1}"
export PT_DECAY="${PT_DECAY:-1}"

export NCCLMINNRINGS=1
export TRUNCATE_NORM=1
export LAMB_BULK=60
export EPS_AFTER_SQRT=1
export NO_SHARD=0
export SKIP_STATE_LOADING=1
export REPEAT_SAMPLER=1
export FORCE_WD=0
export USE_PROJ=0
export DTYPE=float16
export MODEL=bert_24_1024_16
export CKPTINTERVAL=300000000
export HIERARCHICAL=0
export EVALINTERVAL=100000000
export NO_DROPOUT=0
export USE_BOUND=0
export ADJUST_BOUND=0
export WINDOW_SIZE=2000

mkdir -p $CKPTDIR
export OPTIONS='--verbose'
if [ "$DEBUG" = "1" ]; then
    export OPTIONS="$OPTIONS --synthetic_data"
    export NUMSTEPS=5000000000
    export LOGINTERVAL=5
else
    export NUMSTEPS=7038
    export LOGINTERVAL=10
fi
if [ "$RAW" = "1" ]; then
    export OPTIONS="$OPTIONS --raw"
fi
if [ "$EVALRAW" = "0" ]; then
    export OPTIONS="$OPTIONS --eval_use_npz"
fi

# export OPTIONS="$OPTIONS --start_step $NUMSTEPS"

#################################################################
# 1) BERT pre-train phase 1 (with seq-len = 128)
if [ "$NP" = "1" ]; then
    BS=64 ACC=1 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=80 LR=0.005 WARMUP_RATIO=0.2 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "8" ]; then
    BS=512 ACC=1 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.005 WARMUP_RATIO=0.2 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "16" ]; then
    BS=512 ACC=1 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.005 WARMUP_RATIO=0.2 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "32" ]; then
    # 4 nodes x 8 gpu
    BS=4096 ACC=2 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.005 WARMUP_RATIO=0.2 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "64" ]; then
    # 8 nodes x 8 gpu
    BS=12288 ACC=4 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.005 WARMUP_RATIO=0.2 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "128" ]; then
    # 16 nodes x 8 gpu
    BS=16384 ACC=8 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.005 WARMUP_RATIO=0.2 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "256" ]; then
    # 32 nodes x 8 gpu
    BS=32768 ACC=16 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.006 WARMUP_RATIO=0.2843 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "512" ]; then
    # 64 nodes x 8 gpu
    BS=32768 ACC=16 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.006 WARMUP_RATIO=0.2843 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "1024" ]; then
    # 128 nodes x 8 gpu
    BS=32768 ACC=16 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.006 WARMUP_RATIO=0.2843 /opt/benchmarks/bert/mul-hvd.sh
elif [ "$NP" = "2048" ]; then
    # 256 nodes x 8 gpu
    BS=32768 ACC=16 MAX_SEQ_LENGTH=128 MAX_PREDICTIONS_PER_SEQ=20 LR=0.006 WARMUP_RATIO=0.2843 /opt/benchmarks/bert/mul-hvd.sh
fi
echo 'DONE phase1'
#################################################################


