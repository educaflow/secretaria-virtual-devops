#!/bin/bash 


obtener_nombre_repo() {
  local url="$1"
  basename "${url%.git}"
}



cd /opt/secretariavirtual/app
git clone ${APP_GIT_URL}
NOMBRE_REPO=$(obtener_nombre_repo "${APP_GIT_URL}")
cd ${NOMBRE_REPO}
git switch ${APP_GIT_BRANCH}
export AXELOR_CONFIG="../secretaria-virtual-private/axelor-config.properties"
export AXELOR_CONFIG_DB_DEFAULT_URL = jdbc:postgresql://secretariavirtual-db:5432/educaflow
./gradlew clean build
./gradlew --no-daemon run --port 8080 --contextPath /
