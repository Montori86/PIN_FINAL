#!/bin/bash
set -e  # Detiene el script si cualquier comando falla

# Configuración de Variables
CLUSTER_NAME="eks-grupo-2"
NODEGROUP_NAME="ng-grupo-2"
AWS_REGION="us-east-1"
NODE_TYPE="t3.small"
NODE_COUNT=3
SSH_KEY="terraform-key"
ZONES="us-east-1a,us-east-1b,us-east-1c"
SSH_DIR="$HOME/.ssh"
SSH_KEY_PATH="$SSH_DIR/$SSH_KEY"

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

# Verificar si la clave SSH ya existe en AWS
echo "Verificando clave SSH en AWS..."
aws ec2 describe-key-pairs --key-names "$SSH_KEY" --region "$AWS_REGION" > /dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "Clave SSH '$SSH_KEY' no encontrada. Generando nueva clave..."
    
    # Generar clave SSH si no existe localmente
    if [ ! -f "$SSH_KEY_PATH" ]; then
        ssh-keygen -t rsa -b 4096 -f "$SSH_KEY_PATH" -N ""
        echo "Clave SSH generada en $SSH_KEY_PATH"
    fi

    # Subir clave a AWS
    aws ec2 import-key-pair --key-name "$SSH_KEY" --public-key-material fileb://"$SSH_KEY_PATH".pub --region "$AWS_REGION"
    if [ $? -eq 0 ]; then
        echo "Clave SSH '$SSH_KEY' importada a AWS correctamente."
    else
        error_exit "Error al importar la clave SSH en AWS."
    fi
else
    echo "Clave SSH '$SSH_KEY' ya existe en AWS."
fi

# Si el parámetro --delete está presente, eliminar el clúster y salir
if [[ "$1" == "--delete" ]]; then
    echo "Eliminando el clúster de EKS '$CLUSTER_NAME'..."
    eksctl delete cluster --name "$CLUSTER_NAME"
    exit 0
fi

# Crear el clúster en EKS
echo "Creando el clúster de EKS '$CLUSTER_NAME' en la región $AWS_REGION..."
eksctl create cluster \
  --name "$CLUSTER_NAME" \
  --region "$AWS_REGION" \
  --nodes "$NODE_COUNT" \
  --node-type "$NODE_TYPE" \
  --nodegroup-name "$NODEGROUP_NAME" \
  --with-oidc \
  --ssh-access \
  --ssh-public-key "$SSH_KEY" \
  --managed \
  --full-ecr-access \
  --zones "$ZONES" 

# NOTE: AmazonEBSCSIDriverPolicy es una política necesaria porque sin ella, 
# los nodos de EKS no pueden aprovisionar volúmenes persistentes en Amazon EBS. Antes, al desplegar Prometheus, 
# los volúmenes quedaban en estado "Pending" con el error "FailedScheduling: VolumeBinding: context deadline exceeded".  
# Este error ocurría porque los nodos no tenían permisos para manejar EBS, lo que impedía que Kubernetes creara los volúmenes 
# necesarios para los PVCs. Con esta política, los nodos ahora pueden crear, adjuntar y gestionar volúmenes en EBS sin problemas.

echo "Obteniendo el rol de IAM del grupo de nodos..."
NODE_ROLE=$(aws eks describe-nodegroup --cluster-name "$CLUSTER_NAME" --nodegroup-name "$NODEGROUP_NAME" --query "nodegroup.nodeRole" --output text)
if [ -z "$NODE_ROLE" ] || [ "$NODE_ROLE" == "None" ]; then
    error_exit "No se pudo obtener el rol de IAM del grupo de nodos. Verifica si el clúster se creó correctamente."
fi
echo "El rol de IAM del grupo de nodos es: $NODE_ROLE"

echo "Asignando la política de AmazonEBSCSIDriverPolicy al rol de IAM..."
aws iam attach-role-policy --role-name "$(basename $NODE_ROLE)" \
  --policy-arn arn:aws:iam::aws:policy/AmazonEBSCSIDriverPolicy
echo "Política AmazonEBSCSIDriverPolicy asignada correctamente."

echo "El clúster '$CLUSTER_NAME' fue creado exitosamente."
