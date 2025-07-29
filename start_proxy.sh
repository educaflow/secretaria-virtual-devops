#!/bin/bash 

docker network create secretariavirtual_production
docker network create secretariavirtual_staging
docker network create secretariavirtual_develop

docker container stop nginx-proxy
docker container rm nginx-proxy

docker container run --detach \
    --name nginx-proxy \
    --publish 80:80 \
    --volume /var/run/docker.sock:/tmp/docker.sock:ro \
    nginxproxy/nginx-proxy:1.7.1


docker network connect secretariavirtual_production nginx-proxy
docker network connect secretariavirtual_staging nginx-proxy
docker network connect secretariavirtual_develop nginx-proxy
