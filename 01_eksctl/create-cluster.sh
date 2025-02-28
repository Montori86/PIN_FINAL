#!/bin/bash

# Configuración de Variables
CLUSTER_NAME="eks-grupo-2"
AWS_REGION="us-east-1"
NODE_TYPE="t3.small"
NODE_COUNT=3
SSH_KEY="terraform-key"
ZONES="us-east-1a,us-east-1b,us-east-1c"

# Asegurarse de que /usr/local/bin está en el PATH
export PATH=$PATH:/usr/local/bin

# Función para mostrar mensajes de error
function error_exit {
    echo "Error: $1"
    exit 1
}

# Verificar si eksctl está disponible
if ! command -v eksctl &> /dev/null
then
    error_exit "eksctl no está instalado o no está en el PATH."
fi

# Verificar si AWS CLI está configurado y si las credenciales son válidas
aws sts get-caller-identity > /dev/null
if [ $? -eq 0 ]; then
    echo "Credenciales de AWS validadas, procediendo con la creación del clúster..."
else
    error_exit "No se encuentran credenciales de AWS configuradas. Ejecuta 'aws configure' para configurarlas."
fi

# Crear el clúster en EKS
echo "Creando el clúster de EKS '$CLUSTER_NAME' en la región $AWS_REGION..."
eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --nodes "$NODE_COUNT" \
  --node-type "$NODE_TYPE" \
  --with-oidc \
  --ssh-access \
  --ssh-public-key "$SSH_KEY" \
  --managed \
  --full-ecr-access \
  --zones "$ZONES"

# Verificar si el clúster fue creado exitosamente
if [ $? -eq 0 ]; then
    echo "El clúster '$CLUSTER_NAME' fue creado exitosamente."
else
    error_exit "La creación del clúster falló."
fi
