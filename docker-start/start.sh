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
clear
source "${SCRIPTDIR}/whale.sh"
printDockerMachineInfo

# Start docker-compose
echo -e "Run docker-compose..."
"${DOCKER_COMPOSE}" -p "$PROJECT_NAME" --env-file="$DOCKER_DIR/.env" -f "$DOCKER_DIR/docker-compose.yml" up "$@"
echo -e "Docker Machine ${VM_NAME} y Los Contentedores estan Activos...\n"