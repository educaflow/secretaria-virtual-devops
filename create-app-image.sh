#!/bin/bash 

IMAGE_NAME=secretariavirtual-app:1.0.0
DIR_TO_EXPORT=./export-image
IMAGE_FILE_NAME=secretariavirtual-app_1.0.0

if [ "$#" -gt 1 ]; then
    echo "Error: Número de parámetros incorrecto."
    echo "Uso: $0 [--export]"
    exit 1
fi

if [ "$#" -eq 1 ]; then
    if [ "$1" == "--export" ]; then
        EXPORT_IMAGE=true
        echo "Opción '--export' detectada. Se exportará la imagen a ${DIR_TO_EXPORT}/${IMAGE_FILE_NAME}"
    else
        echo "Error: El parámetro '$1' no es válido."
        echo "Si se proporciona, debe ser '--export'."
        exit 1
    fi
fi

docker image rm $IMAGE_NAME

if docker image inspect $IMAGE_NAME > /dev/null 2>&1; then
    echo "Error: La imagen aun existe."
    exit 1
fi

docker buildx build --tag $IMAGE_NAME --no-cache --file ./build-app/Dockerfile ./build-app/src

if [ "$EXPORT_IMAGE" == "true" ]; then
    echo "Exportando imagen....."
    mkdir -p ${DIR_TO_EXPORT}
    rm ${DIR_TO_EXPORT}/${IMAGE_FILE_NAME}
    docker image save -o ${DIR_TO_EXPORT}/${IMAGE_FILE_NAME} ${IMAGE_NAME}
fi



