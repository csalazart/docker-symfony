#!/bin/bash
# Configure apache 2.2 server
# Enviroment variables:
#   HTTP_CONFIGURE_SCRIPT: replace configure script
#   HTTP_LOG_DIR: change apache default log dir
#   HTTP_CONFIGURE_SCRIPT2: additional http configuration

set +e
if [[ -n "$HTTP_CONFIGURE_SCRIPT" && -f "$HTTP_CONFIGURE_SCRIPT" ]] ; then
	exec /bin/sh "$HTTP_CONFIGURE_SCRIPT"
fi

# backup rpm files
mv /etc/httpd/conf/httpd.conf /etc/httpd/conf/httpd.conf.orig
mv /etc/httpd/conf.d/ssl.conf /etc/httpd/conf.d/ssl.conf.orig

mkdir /etc/httpd/mods-enabled /etc/httpd/conf-enabled /etc/httpd/sites-enabled /etc/httpd/ssl

# copy conf files
ln -s /scripts/conf/httpd.conf /etc/httpd/conf/httpd.conf
ln -s /scripts/conf/ssl.conf /etc/httpd/conf-enabled/10-ssl.conf
ln -s /scripts/conf/virtualhost.conf /etc/httpd/conf-enabled/10-virtualhost.conf
ln -s /scripts/conf/default.conf /etc/httpd/sites-enabled/00-default.conf
ln -s /scripts/conf/default-ssl.conf /etc/httpd/sites-enabled/01-default-ssl.conf

# create conf files
echo "ServerName ${HOSTNAME}" > /etc/httpd/conf-enabled/10-servername.conf

if [[ -n "${HTTP_LOG_DIR}" ]] ; then
	if [[ ! -d "${HTTP_LOG_DIR}" ]] ; then 
		mkdir -p "${HTTP_LOG_DIR}"
		chown apache.apache "${HTTP_LOG_DIR}"
		chmod 0775 "${HTTP_LOG_DIR}"
	fi

	cat > /etc/httpd/conf-enabled/00-logging.conf << EOT
ErrorLog ${HTTP_LOG_DIR}/error.log
CustomLog ${HTTP_LOG_DIR}/access.log common
EOT
fi

if [[ -f "/scripts/ssl/docker.ca.crt" ]] ; then
  cp /scripts/ssl/docker.ca.crt /etc/httpd/ssl/docker.ca.crt
  cat /scripts/ssl/docker.ca.crt >> /etc/pki/tls/certs/ca-bundle.crt
fi

# generate ssl certificate
if [[ -f "/scripts/ssl/default.crt" && -f "/scripts/ssl/default.key" ]] ; then
    cp /scripts/ssl/default.crt /etc/httpd/ssl/default.crt
    cp /scripts/ssl/default.key /etc/httpd/ssl/default.key
else
    openssl genrsa -out /etc/httpd/ssl/default.key 2048
    openssl req -new -key /etc/httpd/ssl/default.key -out /root/default.csr << EOF > /dev/null
ES
Madrid

none

${HOSTNAME}



EOF
    openssl x509 -req -days 365 -in /root/default.csr -signkey /etc/httpd/ssl/default.key -out /etc/httpd/ssl/default.crt
fi
chmod 0600 /etc/httpd/ssl/*
chown apache:root /etc/httpd/ssl/*

# additional configuration
if [[ -n "$HTTP_CONFIGURE_SCRIPT2" && -f "$HTTP_CONFIGURE_SCRIPT2" ]] ; then
	/bin/sh "$HTTP_CONFIGURE_SCRIPT2"
fi
