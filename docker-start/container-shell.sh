#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong in step ´$STEP´... Press any key to continue..."' EXIT

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"

if [ -z "$1" ]; then
  echo -e "${BLUE}Debes Ingresar el nombre o el Id del Contenedor"
  exit 
 fi 
 
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
##eval "$(docker-machine env abc17.docker )"
##echo "#!/bin/bash" > export_vars
# echo "docker-machine env "${VM_NAME}"" > export_vars
# echo "exec \"$@\"" >> export_vars
# source "export_vars"
# echo -e source "export_vars"
# cat "export_vars"

STEP="Finalize"
source "whale.sh"
echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}${VM_NAME}${NC} machine with IP ${GREEN}${VM_IP}${NC}"
echo "For help getting started, check out the docs at https://docs.docker.com"
echo "PROMPT Docker.."
echo "exit para Salir del shell"
echo

exec docker exec -it "$1" /bin/bash

