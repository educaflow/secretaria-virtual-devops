#!/bin/bash 

APP_GIT_URL=https://github.com/educaflow/pruebasLorenzo.git
APP_GIT_PRODUCTION_BRANCH=master
APP_GIT_STAGING_BRANCH=release
APP_GIT_DEVELOP_BRANCH=develop

VIRTUAL_HOST_PRODUCTION=secretaria.fpmislata.com
VIRTUAL_HOST_STAGING=secretaria-pre.fpmislata.com
VIRTUAL_HOST_DEVELOP=secretaria-dev.fpmislata.com


# Comprobar si se ha pasado exactamente un argumento
if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
    echo "Error: Número de parámetros incorrecto."
    echo "Uso: $0 <environment> [--no-create-image]"
    echo "  <environment> puede ser: production, staging, o develop."
    echo "  [--no-create-image] es opcional."
    exit 1
fi

# Almacenar el primer (y único) argumento en una variable para mayor claridad
ENVIRONMENT="$1"

# Comprobar el valor del argumento usando case
case "$ENVIRONMENT" in
    "production" | "staging" | "develop")
        echo "Parámetro válido: $ENVIRONMENT"
        # Aquí puedes añadir la lógica para cada entorno
        if [ "$ENVIRONMENT" == "production" ]; then
            echo "Desplegando la aplicación en el entorno de producción..."
            APP_GIT_BRANCH=${APP_GIT_PRODUCTION_BRANCH}
            VIRTUAL_HOST=${VIRTUAL_HOST_PRODUCTION}
        elif [ "$ENVIRONMENT" == "staging" ]; then
            echo "Desplegando la aplicación en el entorno de staging..."
            APP_GIT_BRANCH=${APP_GIT_STAGING_BRANCH}
            VIRTUAL_HOST=${VIRTUAL_HOST_STAGING}
        else # develop
            echo "Desplegando la aplicación en el entorno de desarrollo..."
            APP_GIT_BRANCH=${APP_GIT_DEVELOP_BRANCH}
            VIRTUAL_HOST=${VIRTUAL_HOST_DEVELOP}
        fi
        ;;
    *)
        echo "Error: El parámetro '$ENVIRONMENT' no es un valor válido."
        echo "Los valores permitidos son: production, staging, o develop."
        exit 1
        ;;
esac

NO_CREATE_IMAGE=false # Valor por defecto

if [ "$#" -eq 2 ]; then # Si hay dos parámetros, validamos el segundo
    SECOND_ARG="$2"
    if [ "$SECOND_ARG" == "--no-create-image" ]; then
        NO_CREATE_IMAGE=true
        echo "Opción '--no-create-image' detectada. No se creará la imagen."
    else
        echo "Error: El segundo parámetro '$SECOND_ARG' no es válido."
        echo "Si se proporciona, debe ser '--no-create-image'."
        exit 1
    fi
fi



docker container stop secretariavirtual-${ENVIRONMENT}-app
docker container rm secretariavirtual-${ENVIRONMENT}-app
docker container stop secretariavirtual-${ENVIRONMENT}-db
docker container rm secretariavirtual-${ENVIRONMENT}-db

if [ ${NO_CREATE_IMAGE} == "false" ]; then
    docker image rm secretariavirtual-app:1.0.0
    docker buildx build --tag secretariavirtual-app:1.0.0 --no-cache --file ./build-app/Dockerfile ./build-app/src
fi

rm ./environments/${ENVIRONMENT}/private/axelor-config.properties
cp ../secretaria-virtual-private/axelor-config.${ENVIRONMENT}.properties ./environments/production/private/axelor-config.properties

#  --restart always \

docker container run -d \
  -dit \
  --name secretariavirtual-${ENVIRONMENT}-db \
  --hostname secretariavirtual-db \
  --network secretariavirtual_${ENVIRONMENT} \
  -e TZ=Europe/Madrid \
  -e POSTGRES_USER=educaflow \
  -e POSTGRES_PASSWORD=educaflow \
  -e POSTGRES_DB=educaflow \
  -e PGDATA=/var/lib/postgresql/data/pgdata \
  -v "./environments/production/data/database:/var/lib/postgresql/data" \
  postgres:12.22


docker container run -d \
  -dit \
  --name secretariavirtual-${ENVIRONMENT}-app \
  --hostname secretariavirtual-app \
  --network secretariavirtual_${ENVIRONMENT} \
  -e TZ=Europe/Madrid \
  -e APP_GIT_URL=${APP_GIT_URL} \
  -e APP_GIT_BRANCH=${APP_GIT_BRANCH} \
  -p 80:8080 \
  -e VIRTUAL_HOST=${VIRTUAL_HOST} \
  --memory=""  \
  --memory-swap="" \
  -v "./environments/${ENVIRONMENT}/data/app:/opt/secretariavirtual/data" \
  -v "./environments/${ENVIRONMENT}/private:/opt/secretariavirtual/app/secretaria-virtual-private" \
  secretariavirtual-app:1.0.0



