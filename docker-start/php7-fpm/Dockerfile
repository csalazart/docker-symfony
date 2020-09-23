# See https://github.com/docker-library/php/blob/master/7.1/fpm/Dockerfile
FROM php:7.3.22-fpm
ARG TIMEZONE

MAINTAINER Carlos Salazar <csalazar@paradigmadigital.com>

RUN apt-get update && apt-get install -y \
    openssl \
    git \
    unzip \
	nano \
    make \
    curl

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
&& composer --version

#Install symfony Script
wget https://get.symfony.com/cli/installer -O - | bash


# Set timezone
RUN ln -snf /usr/share/zoneinfo/${TIMEZONE} /etc/localtime && echo ${TIMEZONE} > /etc/timezone \
&& printf '[PHP]\ndate.timezone = "%s"\n', ${TIMEZONE} > /usr/local/etc/php/conf.d/tzone.ini \
&& "date"

# Type docker-php-ext-install to see available extensions
RUN docker-php-ext-install pdo pdo_mysql

# install xdebug
RUN pecl install xdebug \
&& docker-php-ext-enable xdebug \
&& echo "error_reporting = E_ALL" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "display_startup_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "display_errors = On" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_enable=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_connect_back=1" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.idekey=\"PHPSTORM\"" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
&& echo "xdebug.remote_port=9001" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini

#Ajustamos el ssh
RUN mkdir /var/run/sshd
RUN ssh-keygen -A
RUN echo 'root:12345' | chpasswd
ADD sshd_config /etc/ssh/sshd_config
#RUN sed -i -e 4d /var/lib/sss/pubconf/known_hosts
ENV NOTVISIBLE "in users profile"
RUN echo "export VISIBLE=now" >> /etc/profile

COPY scripts /scripts
RUN chmod 0775 /scripts/*.sh

RUN echo 'alias sf="php bin/console"' >> ~/.bashrc

##Scripts
#CMD ["/scripts/start.sh", "start"]

#CMD ["/usr/sbin/sshd", "-D"]

#CMD ["php-fpm7", "-F"]

#ENTRYPOINT ["/bin/bash", "/scripts/start.sh"]
#CMD ["start"]

EXPOSE 9000
EXPOSE 22

WORKDIR /var/www/symfony