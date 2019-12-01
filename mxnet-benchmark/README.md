vim benchmarks/bert.sh
vim benchmarks/bert/mul-hvd.sh

Update docker credentials for ECR on all nodes:

clush --hostfile mpihosts.txt "$(aws ecr get-login --registry-ids 968277166688 --no-include-email --region us-west-2)"

Create new container image and push to ECR:

make imagepush

Pull new container on all nodes:

clush --hostfile mpihosts.txt "docker pull 968277166688.dkr.ecr.us-west-2.amazonaws.com/mxnet-benchmark:latest"

Restart containers on all nodes:

clush --hostfile mpihosts.txt "./start_docker_image_on_node.sh"

Run bert phase1 training:

make test-nccl

make test-bert

Monitor log:

docker exec -it benchmark-test bash -c "tail -F ~/test-ckpt/phase1_log.0"
