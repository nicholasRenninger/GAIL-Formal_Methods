# Build docker images
docker: docker-cpu docker-gpu

docker-cpu:
	./docker_scripts/build_docker.sh

docker-gpu:
	USE_GPU=True ./docker_scripts/build_docker.sh
