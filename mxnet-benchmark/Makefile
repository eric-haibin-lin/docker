export USER="cluster"
export CONTAINER_NAME="mxnet-docker"
export CONTAINER_REGISTRY="haibinlin/bert-docker:test"

image: Dockerfile
	docker build --tag $(CONTAINER_REGISTRY) .

push-image: image
	docker push $(CONTAINER_REGISTRY)
