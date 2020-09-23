#!/bin/bash

if [[ $# == 0 ]] ; then
	exec /bin/sh
elif [[ "$1" == "start" ]] ; then
	shift
	[[ ! -f "/root/configured" ]] && /bin/sh /scripts/configure.sh "$@" && touch /root/configured

	service php71-php-fpm start
	service httpd start
	service sshd start

	stop="service httpd stop; service php71-php-fpm stop; service sshd stop;"
	trap -- "${stop} echo INTERRUPT; trap '' INT; kill -INT $$" INT
	trap -- "${stop} echo TERMINATE; trap '' TERM; kill -TERM $$" TERM

	rm -f /tmp/waitsignal 2> /dev/null
	mkfifo /tmp/waitsignal
	read < /tmp/waitsignal 2> /dev/null
elif [[ "$1" == 'restart' ]] ; then
	service php71-php-fpm restart
	service httpd restart
	service sshd restart
elif [[ "$1" == 'reload' ]] ; then
	service php71-php-fpm reload
	service httpd reload
	service sshd reload
else
	exec "$@"
fi