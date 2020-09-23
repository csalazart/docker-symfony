#!/bin/bash
set +e
WORKDIR="$(readlink -f "$(dirname $0)")"

##Scripts
#RUN git clone --single-branch -b V1.3 https://github.com/csalazart/SF2ShortsCommands.git ~/wwwroot/SF2ShortsCommands
curl -LsS https://symfony.com/installer -o /usr/local/bin/symfony && chmod a+x /usr/local/bin/symfony

cd  /var/www/symfony
echo -e "Iniciando la Instalación de Syfmony\n"
symfony new new-folder 3.4
echo -e "Actualizando la carperta del proyecto...\n....."
cp -Rf new-folder/* .
alias sfconsole="php ./bin/console"
cp /scripts/console .
exec rm -rf new-folder/* && rm -rf new-folder
echo -e "Terminado Proceso Symfony esta Preparado...\n"
#composer update
