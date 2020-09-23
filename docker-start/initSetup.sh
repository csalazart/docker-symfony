#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong in step ´$STEP´... Press any key to continue..."' EXIT

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"
set -e
source "${SCRIPTDIR}/docker-lib.sh"

STEP="Checking if machine ${VM_NAME} exists"
if ! existsVirtualMachine; then
  STEP="Creating docker machine ${VM_NAME}"
  createDockerMachine

  STEP="Assign static ip to ${VM_NAME}"
  staticMachineIp "${VM_IP}"
fi

STEP="Checking status on ${VM_NAME}"
startDockerMachine

STEP="Checking sharedfolder on ${VM_NAME}"
shareVboxDockerFolder

STEP="Setting env"
eval "$("${DOCKER_MACHINE}" env --shell=bash --no-proxy "${VM_NAME}")"

STEP="Finalize"
source "${SCRIPTDIR}/whale.sh"
printDockerMachineInfo

echo "Run docker-compose..."
cd "${DOCKER_DIR}"
##echo "${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$DOCKER_DIR/docker-compose.yml" up --build "$@"
##eval "$("${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$DOCKER_DIR/docker-compose.yml" up --build "$@")"
##"${DOCKER_COMPOSE}" -p "$PROJECT_NAME" --env-file="$DOCKER_DIR/.env" -f "$PROJECT_DIR/docker-compose.yml" up --build "$@"
"${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$DOCKER_DIR/docker-compose.yml" up --build "$@"
echo -e "Docker Machine ${VM_NAME} y Los Contentedores Inicializados y en Ejeción...\n"