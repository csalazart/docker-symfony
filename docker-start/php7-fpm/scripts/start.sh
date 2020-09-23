#!/bin/bash

if [[ $# == 0 ]] ; then
	exec /bin/sh
elif [[ "$1" == "start" ]] ; then

#cp /root/.bashrc /root/.profile /var/www
echo 'cd /var/www/symfony' >> /var/www/.bashrc
echo 'cd /var/www/symfony' >> /var/www/.tcshrc
cat >> /root/.profile <<'EOT'
alias sfconsole="php ./bin/console"
alias symfony-install="cd /var/www/symfony; composer install --no-interaction --optimize-autoloader --prefer-dist"
alias symfony-project="cd /var/www/symfony"
alias composer="php -d memory_limit=-1 /usr/bin/composer"

echo -e "Type '\033[0;32msfconsole\033[0m' to console symfony shorcut"
echo -e "Type '\033[0;32msymfony-install\033[0m' to install symfony2 vendors"
echo -e "Type '\033[0;32msymfony-project\033[0m' to go project dir"

EOT

    service php71-php-fpm start
#	service httpd start
	service sshd start
	
#	/usr/sbin/sshd
#	php-fpm7 -F
	
	stop="php-fpm7 stop;"
	trap -- "${stop} echo INTERRUPT; trap '' INT; kill -INT $$" INT
	trap -- "${stop} echo TERMINATE; trap '' TERM; kill -TERM $$" TERM
	echo -e "... Ejecutando Servicio httpd [start]...\n"
	echo -e "... Ejecutando Servicio php-fpm [start]...\n"
	
	rm -f /tmp/waitsignal 2> /dev/null
	mkfifo /tmp/waitsignal
	read < /tmp/waitsignal 2> /dev/null
else
	exec "$@"
fi