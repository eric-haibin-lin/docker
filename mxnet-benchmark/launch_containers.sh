#!/bin/bash


for host in $(cat mpihosts.txt); do
	echo "Initializing docker container on $host"
	scp -o StrictHostKeyChecking=no start_docker_image_on_node.sh $host:
	ssh -o StrictHostKeyChecking=no $host ./start_docker_image_on_node.sh
done
