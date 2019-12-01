#!/bin/bash

RAMDISK=/media/ramdisk


# create ramdisk if needed
if [ ! -d $RAMDISK ]; then
    mkdir -p $RAMDISK
    mount -t tmpfs -o rw,size=200G tmpfs $RAMDISK
fi

# mask rcnn coco dataset
if [ ! -e $RAMDISK/datasets/coco ]; then
    mkdir -p $RAMDISK/datasets/coco
    cd $RAMDISK/datasets/coco
    wget http://images.cocodataset.org/zips/train2017.zip && \
    unzip train2017.zip && rm train2017.zip && \
    wget http://images.cocodataset.org/zips/val2017.zip && \
    unzip val2017.zip && rm val2017.zip && \
    wget http://images.cocodataset.org/annotations/annotations_trainval2017.zip && \
    unzip annotations_trainval2017.zip && rm annotations_trainval2017.zip && \
    wget http://images.cocodataset.org/annotations/stuff_annotations_trainval2017.zip && \
    unzip stuff_annotations_trainval2017.zip && rm stuff_annotations_trainval2017.zip
fi

if [ ! -e $RAMDISK/models ]; then
    mkdir -p $RAMDISK/models
    cd $RAMDISK/models
    wget https://apache-mxnet.s3-accelerate.dualstack.amazonaws.com/gluon/models/resnet50_v1b-0ecdba34.zip \
    && unzip resnet50_v1b-0ecdba34.zip && rm -f resnet50_v1b-0ecdba34.zip
fi

#AWS_ACCESS_KEY_ID=AKIAIVLHOC3WX26LRESA \
#AWS_SECRET_ACCESS_KEY=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 \
#aws s3 sync s3://aws-ml-platform-datasets/imagenet/480px-q95 ./

