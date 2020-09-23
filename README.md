docker-symfony
==============

# Requisitos y Contenedores version

 **Requisitos**
 - [DockerToolbox no Hyper-V](https://download.docker.com/win/stable/DockerToolbox.exe) (windows) o DockerCE
 - git / gitbash(windows)

**Versiones de Contenedores**
 - mariadb 10.0
 - PHP FPM 7.3.22
 - NGINX
 - ELK Elasticsearch Kibana LOGS

## Inicializar

Directorio de Ejecución de Scripts __docer-star__

Primero Revisar el script __docker-start/vars.sh__ dentro se encuentran valores como 

```bash
PROJECT_NAME="sflocal"
VM_NAME="sflocal.docker"
VM_IP="192.168.99.110"
``` 
que se pueden modificar para generar el IP de la maquina virtual, y los nombres para el proyecto y la maquina.

Una vez Modificado y actualizado *vars.sh* 
Utilizar el script *__initSetup.sh__* (Sólo una Vez, esto reinicia los contenedores) para crear la maquina virtual y los contenedores
una vez hecho eso se pueden utilizar los scripts *__start.sh__* que tambien funcionan como inicializadores si no existen los contenedores

Tambien se pueden ver y modificar parametros en el *docker-compose.yml*

Sientete libre de explorar el resto de scripts algunos de utilidad como:
 - *container-list.sh*: Despliega lista de contenedores, activos e inactivos
 - *win-container-shell.sh(windows)* *container-shell.sh*: entra al Shell del contenedor (ID/Nombre) que indiques de la lista de contenedores
 - *container-ssh.sh*: entra por ssh al Contenedor (ID/Nombre) que indiques de la lista de contenedores
 - *docker-bash-here.sh*: si estas en Windows puede cargar el docker Enviroment para usar el comando docker cuando recibes el mensaje
 ```bash 
 error during connect: Get http://%2F%2F.%2Fpipe%2Fdocker_engine/v1.40/containers/json: open //./pipe/docker_engine: El sistema no puede encontrar el archivo especificado. In the default daemon configuration on Windows, the docker client must be run elevated to connect. This error may also indicate that the docker daemon is not running.
 ``` 

## Ver Los Proyectos

**Symfony:** **IP**:8000 [192.168.99.110:8000](http://192.168.99.110:8000) como el puerto 80

**Symfony:** **IP**:8083 [192.168.99.110:8083](http://192.168.99.110:8083) como el puerto 443

**Conexion ssh** Puerto 2022

**Elasticsearch** Consulta de logs **Kibana** **IP**:8081 [192.168.99.110:8081](http://192.168.99.110:8081)


### Opcionales
 Si deseas personalizar la URL del servicio puedes editar el fichero hosts para agregar una url personalizada 

- Por ejemplo: 

```ini 
# Fichero hosts
192.168.99.110 dockersymfony.local.in 
```

Si usas Windows tienes un acceso Rapido para abrir este Fichero **acceso directo a hosts** 

### Author:
- Carlos A Salazar <csalazart>
- ["GitHub"](https://github.com/csalazart)



------ 

Docs de Origen
==============


[![Build Status](https://secure.travis-ci.org/eko/docker-symfony.png?branch=master)](http://travis-ci.org/eko/docker-symfony)


This is a complete stack for running Symfony 4 (latest version: Flex) into Docker containers using docker-compose tool.

# Installation

First, clone this repository:

```bash
$ git clone https://github.com/eko/docker-symfony.git
```

Next, put your Symfony application into `symfony` folder and do not forget to add `symfony.localhost` in your `/etc/hosts` file.

Make sure you adjust `database_host` in `parameters.yml` to the database container alias "db"

Then, run:

```bash
$ docker-compose up
```

You are done, you can visit your Symfony application on the following URL: `http://symfony.localhost` (and access Kibana on `http://symfony.localhost:81`)

_Note :_ you can rebuild all Docker images by running:

```bash
$ docker-compose build
```

# How it works?

Here are the `docker-compose` built images:

* `db`: This is the MySQL database container (can be changed to postgresql or whatever in `docker-compose.yml` file),
* `php`: This is the PHP-FPM container including the application volume mounted on,
* `nginx`: This is the Nginx webserver container in which php volumes are mounted too,
* `elk`: This is a ELK stack container which uses Logstash to collect logs, send them into Elasticsearch and visualize them with Kibana.

This results in the following running containers:

```bash
> $ docker-compose ps
        Name                       Command               State              Ports
--------------------------------------------------------------------------------------------
dockersymfony_db_1      docker-entrypoint.sh mysqld      Up      0.0.0.0:3306->3306/tcp
dockersymfony_elk_1     /usr/bin/supervisord -n -c ...   Up      0.0.0.0:81->80/tcp
dockersymfony_nginx_1   nginx                            Up      443/tcp, 0.0.0.0:80->80/tcp
dockersymfony_php_1     php-fpm7 -F                      Up      0.0.0.0:9000->9000/tcp
```

# Read logs

You can access Nginx and Symfony application logs in the following directories on your host machine:

* `logs/nginx`
* `logs/symfony`

# Use Kibana!

You can also use Kibana to visualize Nginx & Symfony logs by visiting `http://symfony.localhost:81`.

# Use xdebug!

To use xdebug change the line `"docker.host:127.0.0.1"` in docker-compose.yml and replace 127.0.0.1 with your machine ip addres.
If your IDE default port is not set to 5902 you should do that, too.

# Code license

You are free to use the code in this repository under the terms of the 0-clause BSD license. LICENSE contains a copy of this license.
