#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong in step ´$STEP´... Press any key to continue..."' EXIT

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"
 
STEP="Checking if machine ${VM_NAME} exists"
if ! "${DOCKER_MACHINE}" ls -q | grep -q "^${VM_NAME}$" ; then
	echo "Start $PROJECT_NAME and try again."
	exit 1
fi

set -e

STEP="Checking status on ${VM_NAME}"
if [ "$("${DOCKER_MACHINE}" status "${VM_NAME}")" != "Running" ] ; then
	echo "Start $PROJECT_NAME and try again."
	exit 1
fi

STEP="Setting env"
eval "$("${DOCKER_MACHINE}" env --shell=bash --no-proxy "${VM_NAME}")"
VM_IP="$("${DOCKER_MACHINE}" ip "${VM_NAME}")"

STEP="Finalize"
source "whale.sh"
echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}${VM_NAME}${NC} machine with IP ${GREEN}${VM_IP}${NC}"
echo "For help getting started, check out the docs at https://docs.docker.com"
echo "Inicializando Script Instalación Symfony en contenedor.."
echo "Puede Demorar un tiempo en Completarse.."
echo "A por Café.."
echo
exec winpty docker exec -it "${PROJECT_NAME}_php_1" //bin/bash //scripts/installSF.sh

