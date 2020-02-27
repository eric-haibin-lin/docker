set -ex
export DOCKER_USER=haibinlin
export MXNET_COMMIT=dabdf474
export MXNET_REMOTE=https://github.com/dmlc/mxnet

docker build -t $DOCKER_USER/mxnet:$MXNET_COMMIT \
       --build-arg MXNET_COMMIT=$MXNET_COMMIT \
       --build-arg MXNET_REMOTE=$MXNET_REMOTE \
       -f Dockerfile .

echo "bash buildmx.sh cu100;"
echo "cp /build/dist/mxnet_cu100*.whl /docker/Dockerfile"

docker run -v ~/src/docker:/docker \
       -it $DOCKER_USER/mxnet:$MXNET_COMMIT bash
