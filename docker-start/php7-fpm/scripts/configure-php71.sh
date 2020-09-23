#!/bin/sh
# Configure php-fpm 5.6
# Enviroment variables:
#   PHP_CONFIGURE_SCRIPT: replace configure script
#   PHP_LOG_DIR: change apache default log dir
#   PHP_CONFIGURE_SCRIPT2: additional php configuration

if [[ -n "$PHP_CONFIGURE_SCRIPT" && -f "$PHP_CONFIGURE_SCRIPT" ]] ; then
	exec /bin/sh "$PHP_CONFIGURE_SCRIPT"
fi

set +e
CHROOT=/opt/remi/php71/root
PHP_ETC=/etc/opt/remi/php71
PHP_VAR=/var/opt/remi/php71

if [[ -z "$PHP_LOG_DIR" ]] ; then
	PHP_LOG_DIR="${PHP_VAR}/log/php-fpm"
fi
if [[ ! -d "${PHP_LOG_DIR}" ]] ; then 
	mkdir -p "${PHP_LOG_DIR}"
	chown apache.apache "${PHP_LOG_DIR}"
	chmod 0775 "${PHP_LOG_DIR}"
fi

# backup rpm files
cp "${PHP_ETC}/php-fpm.conf" "${PHP_ETC}/php-fpm.conf.orig"
cp "${PHP_ETC}/php-fpm.d/www.conf" "${PHP_ETC}/php-fpm.d/www.conf.orig"

# modify conf files
sed -i -e 's/^\( *error_log *=\)/;\1/' "${PHP_ETC}/php-fpm.conf"
cat >> "${PHP_ETC}/php-fpm.conf" << EOT
	error_log = /var/log/php-fpm/error.log
EOT

sed -i -e 's/^\( *listen *=\)/;\1/' \
	-e 's/^\( *listen.allowed_clients *=\)/;\1/' \
	-e 's/^\( *slowlog *=\)/;\1/' \
	-e 's/^\( *php_admin_value\[error_log\] *=\)/;\1/' \
    "${PHP_ETC}/php-fpm.d/www.conf"
cat >> "${PHP_ETC}/php-fpm.d/www.conf" << EOT
slowlog = "${PHP_LOG_DIR}/php-slow.log"
php_admin_value[error_log] = "${PHP_LOG_DIR}/php-error.log"
access.log = "${PHP_LOG_DIR}/php-access.log"
pm.status_path = /status
ping.path = /ping
listen = "127.0.0.1:9000"
EOT

# create conf files
echo "date.timezone = Europe/Madrid" > "${PHP_ETC}/php.d/timezone.ini"

cat >> "${PHP_ETC}/php.d/15-xdebug.ini" << EOT
[xdebug]
xdebug.remote_enable=on
xdebug.profiler_enable=0
xdebug.remote_connect_back=on
xdebug.remote_port=9000
xdebug.remote_handler=dbgp
xdebug.remote_mode=req
xdebug.remote_log=/tmp/xdebug.log
xdebug.remote_cookie_expire_time=7200
xdebug.var_display_max_children=128
xdebug.var_display_max_data=2048
xdebug.var_display_max_depth=7
xdebug.max_nesting_level=250
EOT

# initialize log files permisions
touch "${PHP_LOG_DIR}/php-error.log" "${PHP_LOG_DIR}/php-slow.log" "${PHP_LOG_DIR}/php-access.log"
chown root:apache "${PHP_LOG_DIR}/php-error.log" "${PHP_LOG_DIR}/php-slow.log" "${PHP_LOG_DIR}/php-access.log"
chmod 0664 "${PHP_LOG_DIR}/php-error.log" "${PHP_LOG_DIR}/php-slow.log" "${PHP_LOG_DIR}/php-access.log"

# create links
if [[ -n "$CHROOT" ]] ; then
	ln -s "${CHROOT}/usr/bin/php" /usr/bin/php
	ln -s "${PHP_ETC}/php.ini" /etc/php.ini
	ln -s "${PHP_ETC}/php.d/" /etc/php.d
	ln -s "${PHP_ETC}/php-fpm.conf" /etc/php-fpm.conf
	ln -s "${PHP_ETC}/php-fpm.d/" /etc/php-fpm.d
	ln -s "${PHP_VAR}/log/php-fpm" /var/log/php-fpm
	ln -s "${PHP_VAR}/run/php-fpm" /var/run/php-fpm
fi

# extra configuration
if [[ -n "$PHP_CONFIGURE_SCRIPT2" && -f "$PHP_CONFIGURE_SCRIPT2" ]] ; then
	/bin/sh "$PHP_CONFIGURE_SCRIPT2"
fi
