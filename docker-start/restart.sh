#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong in step ´$STEP´... Press any key to continue..."' EXIT

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"
source "${SCRIPTDIR}/docker-lib.sh"

STEP="Checking if machine ${VM_NAME} exists"
"${VBOXMANAGE}" list vms | grep \""${VM_NAME}"\" &> /dev/null
VM_EXISTS_CODE=$?

set -e

if [ $VM_EXISTS_CODE -eq 1 ]; then
  "${DOCKER_MACHINE}" rm -f "${VM_NAME}" &> /dev/null || :
  rm -rf ~/.docker/machine/machines/"${VM_NAME}"
  VM_BOOT2DOCKER="https://github.com/boot2docker/boot2docker/releases/download/${VM_VERSION}/boot2docker.iso"
  #set proxy variables if they exists
  if [ "${HTTP_PROXY}" ]; then
    PROXY_ENV="$PROXY_ENV --engine-env HTTP_PROXY=$HTTP_PROXY"
  fi
  if [ "${HTTPS_PROXY}" ]; then
    PROXY_ENV="$PROXY_ENV --engine-env HTTPS_PROXY=$HTTPS_PROXY"
  fi
  if [ "${NO_PROXY}" ]; then
    PROXY_ENV="$PROXY_ENV --engine-env NO_PROXY=$NO_PROXY"
  fi
  "${DOCKER_MACHINE}" create -d virtualbox  --virtualbox-boot2docker-url "${VM_BOOT2DOCKER}" $PROXY_ENV "${VM_NAME}" 
  staticMachineIp "${VM_NAME}" "${VM_IP}"
  "${DOCKER_MACHINE}" stop "${VM_NAME}"
fi

STEP="Checking status on ${VM_NAME}"
VM_STATUS="$("${DOCKER_MACHINE}" status "${VM_NAME}" 2>&1)"
if [ "${VM_STATUS}" != "Running" ]; then
  "${DOCKER_MACHINE}" start "${VM_NAME}"
  yes | "${DOCKER_MACHINE}" regenerate-certs "${VM_NAME}"
fi

STEP="Checking sharedfolder on ${VM_NAME}"
if ! "${VBOXMANAGE}" showvminfo "${VM_NAME}" --machinereadable | grep -q "SharedFolderName[^=]*=\"$PROJECT_NAME\"" ; then
  set +e
  echo "Share on $VM_NAME folder $PROJECT_DIR with name $PROJECT_NAME"
  "${VBOXMANAGE}" sharedfolder add "${VM_NAME}" --name "$PROJECT_NAME" --hostpath "$PROJECT_DIR" --transient
  "${DOCKER_MACHINE}" ssh "${VM_NAME}" "sudo mkdir -p '$PROJECT_DIR' ; sudo /sbin/mount.vboxsf -o uid=48,gid=48 '$PROJECT_NAME' '$PROJECT_DIR'"
  set -e
fi

STEP="Setting env"
eval "$("${DOCKER_MACHINE}" env --shell=bash --no-proxy "${VM_NAME}")"
VM_IP="$("${DOCKER_MACHINE}" ip "${VM_NAME}")"

STEP="Finalize"
source "whale.sh"
echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}${VM_NAME}${NC} machine with IP ${GREEN}${VM_IP}${NC}"
echo

echo "Run docker-compose..."
cd "${DOCKER_DIR}"
#echo "${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$DOCKER_DIR/docker-compose.yml" up --build "$@"
#"$("${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$DOCKER_DIR/docker-compose.yml" restart "$@")"
"${DOCKER_COMPOSE}" -p "$PROJECT_NAME" -f "$PROJECT_DIR/docker-compose.yml" restart "$@"
