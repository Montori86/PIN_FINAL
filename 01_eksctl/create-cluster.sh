#!/bin/bash

# Variables
CLUSTER_NAME=eks-mundos-e
AWS_REGION=us-east-1

# Asegurarse de que /usr/local/bin está en el PATH
export PATH=$PATH:/usr/local/bin

# Verificar si eksctl está disponible
if ! command -v eksctl &> /dev/null
then
    echo "Error: eksctl no está instalado o no está en el PATH"
    exit 1
fi

# Set AWS credentials 
aws sts get-caller-identity >> /dev/null
if [ $? -eq 0 ]
then
  echo "Credenciales testeadas, proceder con la creacion de cluster."

  # Creación del cluster en EKS
  eksctl create cluster \
    --name "$CLUSTER_NAME" \
    --region us-east-1 \
    --nodes 3 \
    --node-type t3.small \
    --with-oidc \
    --ssh-access \
    --ssh-public-key pin-grupo10 \
    --managed \
    --full-ecr-access \
    --zones us-east-1a,us-east-1b,us-east-1c

  if [ $? -eq 0 ]; then
    echo "Cluster creado exitosamente con eksctl."
  else
    echo "Error: La creación del cluster falló al ejecutar eksctl"
    exit 1
  fi
else
  echo "No se encuentran credenciales de AWS configuradas. Por favor, ejecuta 'aws configure' para configurar las credenciales adecuadas"
  echo "El setup del cluster ha fallado."
  exit 1
fi