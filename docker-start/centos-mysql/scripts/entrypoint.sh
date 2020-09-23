#!/bin/bash
set -e
source /scripts/config.sh

if [[ $# == 0 ]] ; then
	exec /bin/bash
elif [[ "$1" == "start" ]] ; then
	shift
	[[ ! -f "/root/configured" ]] && /bin/sh /scripts/configure.sh "$@" && touch /root/configured

	[[ -f "$PIDFILE" ]] && rm "$PIDFILE"
	service mysqld start
	stop="service mysqld stop;"
	trap -- "${stop} echo INTERRUPT; trap '' INT; kill -INT $$" INT
	trap -- "${stop} echo TERMINATE; trap '' TERM; kill -TERM $$" TERM
	[[ ! -f "${DATADIR}/configured-sql" ]] && /bin/sh /scripts/sql.sh "$@" && touch "${DATADIR}/configured-sql"

	rm -f /tmp/waitsignal 2> /dev/null
	mkfifo /tmp/waitsignal
	read < /tmp/waitsignal 2> /dev/null
elif [[ "$1" == 'mysqld' ]] ; then
	shift
	[[ ! -f "/root/configured" ]] && /bin/sh /scripts/configure.sh "$@" && touch /root/configured
	
	[[ -f "$PIDFILE" ]] && rm "$PIDFILE"
	/usr/bin/mysqld_safe &
	pid=$!
	trap -- "kill $pid" SIGINT

	[[ ! -f "/root/configured-sql" ]] && /bin/sh /scripts/sql.sh && touch "/root/configured-sql"
	wait $pid
else
	exec "$@"
fi
