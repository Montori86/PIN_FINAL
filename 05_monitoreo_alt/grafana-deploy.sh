#!/bin/bash

# Definir variables
SCRIPT_DIR=$(dirname "$0")
GRAFANA_VALUES="$SCRIPT_DIR/grafana.yml"
ADMIN_PASSWORD="grupo-02"
NODEGROUP_NAME="ng-grupo-2"
NAMESPACE="grafana"

# Verificar si el script fue llamado con --delete
if [[ "$1" == "--delete" ]]; then
  echo "Eliminando todos los recursos de Grafana..."
  
  # Eliminar cualquier instalación previa de Grafana
  helm uninstall grafana -n $NAMESPACE --delete && kubectl delete namespace $NAMESPACE
fi

# Crear el namespace para Grafana
kubectl create namespace $NAMESPACE

# Instalar Grafana usando Helm y el archivo de configuración local
helm install grafana grafana/grafana \
    --namespace $NAMESPACE \
    --set persistence.storageClassName="gp3-immediate" \
    --set persistence.enabled=true \
    --set adminPassword="$ADMIN_PASSWORD" \
    --values "$GRAFANA_VALUES" \
    --set service.type=LoadBalancer

# NOTE: el cambio de gp2 a gp3-immediate se hace para que la StorageClass este configurada para provisionar volúmenes de tipo "gp3" en AWS con la 
# opción "Immediate", lo que significa que el volumen se provisiona de inmediato sin esperar a que se consuma, lo que mejora el tiempo de provisión.


