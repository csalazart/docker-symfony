#!/bin/bash
WORKDIR="$(readlink -f "$(dirname $0)")"
IMAGE_NAME=centos-mysql
IMAGE_TAG=6.9
CONTAINER_NAME="ct-${IMAGE_NAME}"
VOLUMES=( )
EXPOSE=( -p 3306:3306 )
ENVIRON=( -e MYSQL_ROOT_PASSWORD=1234 )

if [[ "$1" == "build" ]] ; then
	docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" .
elif [[ "$1" == "share" ]] ; then
	VBoxManage sharedfolder add dockervm --name "$IMAGE_NAME" --hostpath "$WORKDIR" --transient --automount
	docker-machine ssh dockervm "sudo mkdir -p '$WORKDIR' ; sudo /sbin/mount.vboxsf '$IMAGE_NAME' '$WORKDIR'"
elif [[ "$1" == "up" ]] ; then
	#IMAGE_ID=$(docker images | grep "^${IMAGE_NAME} \+${IMAGE_TAG} " | head -1 | tr -s ' ' | cut -f3 -d ' ')
	docker images | grep "^${IMAGE_NAME} \+${IMAGE_TAG} "
	docker run -it --name "${CONTAINER_NAME}" --hostname "${CONTAINER_NAME}" \
		"${ENVIRON[@]}" "${EXPOSE[@]}" "${VOLUMES[@]}" "${IMAGE_NAME}:${IMAGE_TAG}"
elif [[ "$1" == "start" ]] ; then
	#CONTAINER_ID=$(docker ps -a | grep "${IMAGE_NAME}:${IMAGE_TAG}" | head -1 | cut -f 1 -d ' ')
	docker ps -a | grep "${IMAGE_NAME}:${IMAGE_TAG}"
	docker start -ai "${CONTAINER_NAME}"
elif [[ "$1" == "stop" ]] ; then
	docker ps | grep "${IMAGE_NAME}:${IMAGE_TAG}"
	docker stop "${CONTAINER_NAME}"
elif [[ "$1" == "down" ]] ; then
	docker ps -a | grep "${IMAGE_NAME}:${IMAGE_TAG}"
	docker rm -v "${CONTAINER_NAME}"
elif [[ "$1" == "rmi" ]] ; then
	docker images | grep "^${IMAGE_NAME} \+${IMAGE_TAG} " && docker rmi "${IMAGE_NAME}:${IMAGE_TAG}"
elif [[ "$1" == "shell" ]] ; then
	if docker ps | grep "${IMAGE_NAME}:${IMAGE_TAG}" ; then
		docker exec -it "${CONTAINER_NAME}" /bin/bash
	else
		docker run -it --name "${CONTAINER_NAME}" --hostname "${CONTAINER_NAME}" \
			"${EXPOSE[@]}" "${VOLUMES[@]}" "${IMAGE_NAME}:${IMAGE_TAG}" /bin/bash
	fi
else
	echo "Usage: $0 build|share|up|start|stop|down|shell|rmi"
fi
