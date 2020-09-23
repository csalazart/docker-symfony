#!/bin/bash

if [[ -n "$CONFIGURE_SQL" && -f "$CONFIGURE_SQL" ]] ; then
	exec /bin/sh "$CONFIGURE_SQL"
fi

# environment build args
mysql=( mysql )
MYSQL_ROOT_PASSWORD=${MYSQL_ROOT_PASSWORD:-""}
MYSQL_DATABASE=${MYSQL_DATABASE:-""}
MYSQL_USER=${MYSQL_USER:-""}
MYSQL_PASSWORD=${MYSQL_PASSWORD:-""}

echo
    echo "== Configure root access: mysql -uroot '-p${MYSQL_ROOT_PASSWORD}' -h ${HOSTNAME}"
echo "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}' WITH GRANT OPTION ;" | "${mysql[@]}"

# configure application database
if [ "$MYSQL_DATABASE" ]; then
	echo "== Create application database: ${MYSQL_DATABASE}"
	echo "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\` ;" | "${mysql[@]}"
fi

if [ "$MYSQL_USER" -a "$MYSQL_PASSWORD" ]; then
	echo "== Create applicacion access: mysql '-u${MYSQL_USER}' '-p${MYSQL_PASSWORD}' -h ${HOSTNAME} ${MYSQL_DATABASE}"
	echo "CREATE USER '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}' ;" | "${mysql[@]}"

	if [ "$MYSQL_DATABASE" ]; then
		echo "GRANT ALL ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%' ;" | "${mysql[@]}"
	fi

	echo 'FLUSH PRIVILEGES ;' | "${mysql[@]}"
fi

if [[ -n "$CONFIGURE_SQL2" && -f "$CONFIGURE_SQL2" ]] ; then
	/bin/sh "$CONFIGURE_SQL2"
fi
