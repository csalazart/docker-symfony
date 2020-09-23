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


This results in the following running containers:

```bash
$ docker ps
CONTAINER ID        IMAGE               COMMAND                  CREATED             STATUS              PORTS                                          NAMES
5acf9c07e546        willdurand/elk      "/usr/bin/supervisor…"   21 hours ago        Up 29 seconds       0.0.0.0:8081->80/tcp                           sflocal_elk_1
f0efa5d52c00        sflocal_nginx       "nginx"                  21 hours ago        Up 29 seconds       0.0.0.0:8000->80/tcp, 0.0.0.0:8083->443/tcp    sflocal_nginx_1
3b4704b50b26        sflocal_php         "docker-php-entrypoi…"   21 hours ago        Up 30 seconds       0.0.0.0:9000->9000/tcp, 0.0.0.0:2022->22/tcp   sflocal_php_1
97b8568287d4        adminer             "entrypoint.sh docke…"   26 hours ago        Up 30 seconds       0.0.0.0:8080->8080/tcp                         sflocal_adminer_1
```

# Read logs

You can access Nginx and Symfony application logs in the following directories on your host machine:

* `logs/nginx`
* `logs/symfony`

# Use Kibana!

You can also use Kibana to visualize Nginx & Symfony logs by visiting `http://symfony.localhost:81`.


### Author:
- Carlos A Salazar <csalazart>
- ["GitHub"](https://github.com/csalazart)
