FROM centos:6.9

MAINTAINER Carlos Salazar <csalazar@paradigmadigital.com>

WORKDIR /root

# mysql-server
RUN yum -y install mysql-server mysql
RUN yum clean all

COPY scripts/ /scripts
RUN chmod 0775 /scripts/*.sh

EXPOSE 3306
VOLUME ["/var/lib/mysql"]

ENTRYPOINT ["/bin/bash", "/scripts/entrypoint.sh"]
CMD ["start"]