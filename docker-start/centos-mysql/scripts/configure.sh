#!/bin/bash
set -e
WORKDIR="$(readlink -f "$(dirname $0)")"

if [[ -n "$CONFIGURE_SCRIPT" && -f "$CONFIGURE_SCRIPT" ]] ; then
	exec /bin/sh "$CONFIGURE_SCRIPT"
fi

source "${WORKDIR}/config.sh"

localedef -c -f UTF-8 -i es_ES es_ES.UTF-8
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
echo "ENVIRON=DOCKER" >> /etc/environment

cp "${WORKDIR}/conf/my.cnf" /etc/my.cnf

if [[ ! -d "$DATADIR" || $(ls "$DATADIR" | wc -l) == 0 ]] ; then
	# install database
	mkdir -p "$DATADIR"
	chmod 0755 "$DATADIR"
	chown -R "$USER:$GROUP" "$DATADIR"

	echo 'Running mysql_install_db...'
	mysql_install_db --user="$USER" --datadir="$DATADIR" --rpm > /dev/null
	chown -R "$USER:$GROUP" "$DATADIR"
	chmod 0755 "$DATADIR"
	echo 'Finished mysql_install_db'


	# start mysqld
	#runuser -s /bin/bash -g "$GROUP" "$USER" -c "/usr/libexec/mysqld --pid-file="$PIDFILE" --user="$USER" --datadir="$DATADIR" --skip-networking" &
	echo 'Starting mysql for first time'
	/usr/libexec/mysqld --skip-networking > /dev/null 2>&1 &
	pid="$!"

	mysql=( mysql )
	for i in {10..0}; do
		if \! ps -p $pid &> /dev/null ; then
			echo >&2 'MySQL init process failed.'
			tail /var/log/mysqld.log >&2
			exit 1
		elif echo 'SELECT 1' | "${mysql[@]}" &> /dev/null; then
	        break
	    fi
		echo 'MySQL init process in progress...'
		sleep 1
	done
	if [ "$i" = 0 ]; then
		echo >&2 'MySQL init process failed.'
		tail /var/log/mysqld.log >&2
		exit 1
	fi
	echo 'Mysql is running'

	# configure database
	mysql_tzinfo_to_sql /usr/share/zoneinfo | "${mysql[@]}" mysql

	echo 'Stop mysql.'
	if ! kill -s TERM "$pid" || ! wait "$pid"; then
        echo >&2 'MySQL stop process failed.'
        exit 1
	fi

	chown -R "$USER:$GROUP" "$DATADIR"
	test -f "$PIDFILE" && rm "$PIDFILE"

	echo 'MySQL init process done. Ready for start up.'
fi

if [[ -n "$CONFIGURE_SCRIPT2" && -f "$CONFIGURE_SCRIPT2" ]] ; then
	/bin/sh "$CONFIGURE_SCRIPT2"
fi
