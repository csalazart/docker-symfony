#!/bin/bash

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"
source "${SCRIPTDIR}/docker-lib.sh"
echo -e "Valores Detectados:\n"
echo -e "${BLUE}VM_IP:" "${GREEN}${VM_IP}"
echo -e "${BLUE}VM_NAME:" "${GREEN}${VM_NAME}"
echo -e "${BLUE}docker-dir:" "${GREEN}${DOCKER_DIR}"
echo -e "${BLUE}project-dir:" "${GREEN}${PROJECT_DIR}"
echo -e "${BLUE}docker-machine:" "${GREEN}${DOCKER_MACHINE}"
echo -e "${BLUE}docker-compose:" "${GREEN}${DOCKER_COMPOSE}"
echo -e "${BLUE}vboxmanage:" "${GREEN}${VBOXMANAGE}"
echo -e "${BLUE}scriptDIR:" "${GREEN}${SCRIPTDIR}"
#echo -e "${GREEN}[Opcional] ${BLUE}PuTTY:" "${GREEN}${PuTTY}${NC}"
export TEST_UNO=uno
export TEST_DOS=dos

for VAR in `cat .env ` #LINEA guarda el resultado del fichero datos.txt
do
    if [[ $VAR = *"="* ]]; then
		echo "export $VAR"
		export $VAR
		echo "Exportando $VAR" #Muestra resultado.
	fi
done

env | grep MYSQL
env | grep TEST

STEP="Load Projects configuration"
readProjectsConfig

STEP="Checking sharedfolder on ${VM_NAME}"
shareVboxDockerFolder

STEP="Checking sharedfolder of projects on ${VM_NAME}"
shareVboxProjectsFolder

echo "Variables CODE_NUM: ${CODE_VOLUME}"
echo "Variables CODE_NAME: ${CODE_NAME}"

# Carga el BASH con las Variables activas.
#/bin/bash