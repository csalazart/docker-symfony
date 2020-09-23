#!/bin/bash

trap '[ "$?" -eq 0 ] || read -p "Looks like something went wrong in step ´$STEP´... Press any key to continue..."' EXIT

STEP="Load config vars"
SCRIPTDIR="$(dirname "$(readlink -f "$0")")"
source "${SCRIPTDIR}/vars.sh"

STEP="Finalize"
source "whale.sh"
echo -e "${BLUE}docker${NC} is configured to use the ${GREEN}${VM_NAME}${NC} machine with IP ${GREEN}${VM_IP}${NC}"
echo "SSH Docker.."
echo "exit para Salir del shell"
echo
echo -e "Connectando SSH via root@${VM_IP}"
echo -e "Pass: 12345 \n"

ssh -t root@"${VM_IP}" -p2022 "cd /var/www/symfony; exec \$SHELL --login"