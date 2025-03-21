#!/bin/bash

# Detener el script si ocurre un error
set -e

# Definir variables
SCRIPT_DIR=$(dirname "$0")
GRAFANA_VALUES="$SCRIPT_DIR/grafana.yaml"
ADMIN_PASSWORD="grupo-02"
NODEGROUP_NAME="ng-grupo-2-grafana"
NAMESPACE="grafana"

# Verificar si el archivo de configuración grafana.yml existe
if [ ! -f "$GRAFANA_VALUES" ]; then
  echo "Error: El archivo grafana.yaml no existe en la ruta $GRAFANA_VALUES"
  exit 1
fi

# Verificar si el script fue llamado con --delete
if [[ "$1" == "--delete" ]]; then
  echo "Eliminando todos los recursos de Grafana..."
  
  # Eliminar cualquier instalación previa de Grafana
  helm uninstall grafana -n $NAMESPACE
  
  # Eliminar el namespace
  kubectl delete namespace $NAMESPACE

  exit 0
fi

# Comprobar si el namespace grafana ya existe, si no, crearlo
if ! kubectl get namespace $NAMESPACE &>/dev/null; then
  kubectl create namespace $NAMESPACE
else
  echo "El namespace $NAMESPACE ya existe."
fi

# Instalar Grafana usando Helm y el archivo de configuración local
helm install grafana grafana/grafana \
    --namespace $NAMESPACE \
    --set persistence.enabled=true \
    --set adminPassword="$ADMIN_PASSWORD" \
    --values "$GRAFANA_VALUES" \
    --set service.type=LoadBalancer

# NOTE: El volumen persistente se deshabilita estableciendo persistence.enabled=false.
# Esto hace que los datos de Grafana no se conserven entre reinicios de los pods.

