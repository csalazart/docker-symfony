#!/bin/bash
set +e
if [[ -n "$CONFIGURE_SCRIPT" && -f "$CONFIGURE_SCRIPT" ]] ; then
	exec /bin/sh "$CONFIGURE_SCRIPT"
fi

WORKDIR="$(readlink -f "$(dirname $0)")"

localedef -c -f UTF-8 -i es_ES es_ES.UTF-8
ln -sf /usr/share/zoneinfo/Europe/Madrid /etc/localtime
echo "ENVIRON=DOCKER" >> /etc/environment

/bin/sh "$WORKDIR/configure-sshd.sh"
/bin/sh "$WORKDIR/configure-httpd.sh"
/bin/sh "$WORKDIR/configure-php71.sh"

if [[ -n "$CONFIGURE_SCRIPT2" && -f "$CONFIGURE_SCRIPT2" ]] ; then
	/bin/sh "$CONFIGURE_SCRIPT2"
fi
