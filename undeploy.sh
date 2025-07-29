#!/bin/bash 


# Comprobar si se ha pasado exactamente un argumento
if [ "$#" -ne 1 ]; then
    echo "Error: Se espera exactamente un parámetro."
    echo "Uso: $0 <environment>"
    echo "Donde <environment> puede ser: production, staging, o develop"
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
            echo "Eliminando la aplicación en el entorno de producción..."
        elif [ "$ENVIRONMENT" == "staging" ]; then
            echo "Eliminando la aplicación en el entorno de staging..."
        else # develop
            echo "Eliminando la aplicación en el entorno de desarrollo..."

        fi
        ;;
    *)
        echo "Error: El parámetro '$ENVIRONMENT' no es un valor válido."
        echo "Los valores permitidos son: production, staging, o develop."
        exit 1
        ;;
esac





docker container stop secretariavirtual-${ENVIRONMENT}-app
docker container rm secretariavirtual-${ENVIRONMENT}-app
docker container stop secretariavirtual-${ENVIRONMENT}-db
docker container rm secretariavirtual-${ENVIRONMENT}-db


