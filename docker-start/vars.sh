#!/bin/bash
DOCKER_DIR="$(readlink -f "$(dirname "$0")")"
PROJECT_DIR="$(readlink -f "${DOCKER_DIR}/..")"
PROJECT_NAME="sflocal"
VM_NAME="sflocal.docker"
VM_IP="192.168.99.110"
## Version del Bootloader
#VM_VERSION=v19.03.1

## For windows Enviroment .env
for VAR in `cat .env ` #LINEA guarda el resultado del fichero datos.txt
do
    if [[ $VAR = *"="* ]]; then
		#echo "export $VAR"
		export $VAR
		#echo "Exportando $VAR" #Muestra resultado.
	fi
done

BLUE='\033[1;34m'
GREEN='\033[0;32m'
NC='\033[0m'

#clear all_proxy if not socks address
if  [[ $ALL_PROXY != socks* ]]; then
  unset ALL_PROXY
fi
if  [[ $all_proxy != socks* ]]; then
  unset all_proxy
fi

case "$(uname -s)" in
  Darwin)
    echo 'Mac OS X Unsuported'
    exit 1
    ;;

  Linux)
    DOCKER_MACHINE="$(type -p docker-machine)"
    DOCKER_COMPOSE="$(type -p docker-compose)"
	DOCKER="$(type -p docker)"
    VBOXMANAGE="$(type -p VBoxManage)"
    PUTTY="$HOME/.wine/drive_c/Program Files (x86)/PuTTY/putty.exe"
    trap '[ "$?" -eq 0 ] || echo "Looks like something went wrong in step ´$STEP´..."' EXIT
    ;;

  CYGWIN*|MINGW32*|MINGW64*|MSYS*)
    DOCKER_DIR="$(cygpath -u "$DOCKER_DIR")"
    PROJECT_DIR="$(cygpath -u "${PROJECT_DIR}")"

    if [ -n "${DOCKER_TOOLBOX_INSTALL_PATH}" ]; then
      DOCKER_MACHINE="${DOCKER_TOOLBOX_INSTALL_PATH}/docker-machine.exe"
      DOCKER_COMPOSE="${DOCKER_TOOLBOX_INSTALL_PATH}/docker-compose.exe"
	  DOCKER="${DOCKER_TOOLBOX_INSTALL_PATH}/docker.exe"
    else
      DOCKER_MACHINE="$(type -p docker-machine.exe)"
      DOCKER_COMPOSE="$(type -p docker-compose.exe)"
	  DOCKER="$(type -p docker.exe)"
    fi
    
    if [ -n "$VBOX_MSI_INSTALL_PATH" ]; then
      VBOXMANAGE="${VBOX_MSI_INSTALL_PATH}VBoxManage.exe"
    elif [ -n "$VBOX_INSTALL_PATH" ]; then
      VBOXMANAGE="${VBOX_INSTALL_PATH}VBoxManage.exe"
    else
      VBOXMANAGE="$(type -p VBoxManage.exe)"
    fi

    if [ -d "C:\Program Files (x86)\PuTTY" ]; then
      PUTTY="C:\Program Files (x86)\PuTTY\putty.exe"
    else
      PUTTY="$(type -p putty.exe)"
    fi

    docker () {
      MSYS_NO_PATHCONV=1 docker.exe "$@"
    }
    export -f docker
    ;;

  *)
    echo 'Unsuported OS' 
    exit 1
    ;;

esac

if [ ! -f "${DOCKER_MACHINE}" ]; then
  echo "Docker Machine is not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi

if [ ! -f "${DOCKER_COMPOSE}" ]; then
  echo "Docker Compose is not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi

if [ ! -f "${VBOXMANAGE}" ]; then
  echo "VirtualBox is not installed. Please re-run the Toolbox Installer and try again."
  exit 1
fi
