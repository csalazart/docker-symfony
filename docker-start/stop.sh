#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong in step ´$STEP´... Press any key to continue..."' EXIT

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"
set -e
source "${SCRIPTDIR}/docker-lib.sh"

STEP="Checking if machine ${VM_NAME} exists"
if ! existsVirtualMachine; then
  echo "Docker machine not created"
  exit 0
fi


STEP="Checking status on ${VM_NAME}"
if ! runningDockerMachine ; then
  echo "Docker machine already stopped"
  exit 0
fi

STEP="Setting env"
eval "$("${DOCKER_MACHINE}" env --shell=bash --no-proxy "${VM_NAME}")"

STEP="Finalize"
source "${SCRIPTDIR}/whale.sh"
printDockerMachineInfo

set +e

# Stop docker-compose
echo "Stop docker-compose..."
cd "$DOCKER_DIR"
"${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$DOCKER_DIR/docker-compose.yml" stop "$@"

echo "Stop docker-machine..."
"${DOCKER_MACHINE}" stop "${VM_NAME}"
