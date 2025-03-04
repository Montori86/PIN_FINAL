#!/bin/bash

# Definir variables
SCRIPT_DIR=$(dirname "$0")
GRAFANA_VALUES="$SCRIPT_DIR/grafana.yml"
ADMIN_PASSWORD="grupo-02"

# Crear el namespace para Grafana
kubectl create namespace grafana

# Instalar Grafana usando Helm y el archivo de configuración local
helm install grafana grafana/grafana \
    --namespace grafana \
    --set persistence.storageClassName="gp2" \
    --set persistence.enabled=true \
    --set adminPassword="$ADMIN_PASSWORD" \
    --values "$GRAFANA_VALUES" \
    --set service.type=LoadBalancer
