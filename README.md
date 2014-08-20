docker-webproxy
===============

Web proxy for Docker containers.
Inspired [jwilder/nginx-proxy](https://github.com/jwilder/nginx-proxy)

## Install & Build

```
git clone git@github.com:odoku/docker-webproxy.git
docker build -t odoku/webproxy ./docker-webproxy
```

## Run

```
docker run -i -d -p 80:80 -p 443:443 -p 22 -v /var/run/docker.sock:/var/run/docker.sock --name=webproxy odoku/webproxy
```

### Caution

It is not perfection.
It is necessary to perform the following tasks.

```
ssh webproxy  # Login to webproxy container.
sudo service supervisor start
[sudo] password for docker:  # Type "docker"
```

## Usage

```
docker run -d -e VIRTUAL_HOST=[virtual_host_name, ...] -p 80 -p 443 --name=[container_name] [image_name]
```
