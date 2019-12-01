export USER=cluster
export CONTAINER_NAME=mxnet-docker
ECRENDPOINT=968277166688.dkr.ecr.us-west-2.amazonaws.com
ECRNAME=mxnet-benchmark
HOSTS=hosts
PORT=2022

image: Dockerfile
	docker build --tag $(ECRNAME):latest .

imagepush: image
	docker tag $(ECRNAME):latest $(ECRENDPOINT)/$(ECRNAME):latest
	docker push $(ECRENDPOINT)/$(ECRNAME):latest

runcontainer:
	clush --hostfile $(HOSTS) "bash $(PWD)/start_docker_image_on_node.sh $(CONTAINER_NAME) $(USER)"
	-docker kill $(CONTAINER_NAME)
	./start_container.sh $(CONTAINER_NAME) haibinlin/bert-docker:test

sync-host: runcontainer
	scp -P$(PORT) -i ssh_cluster_key.pem $(HOSTS) $(USER)@localhost:mpihosts.txt

test-nccl: sync-host
	ssh -p$(PORT) -i ssh_cluster_key.pem $(USER)@localhost /opt/benchmarks/run_benchmark.sh nccl

test-bert: hosts2
	scp -P$(PORT) -i ssh_cluster_key.pem $(HOSTS) $(USER)@localhost:mpihosts.txt
	ssh -p$(PORT) -i ssh_cluster_key.pem $(USER)@localhost /opt/benchmarks/run_benchmark.sh bert
