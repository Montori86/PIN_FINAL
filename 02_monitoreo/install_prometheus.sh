#!/bin/bash
set -e

NAMESPACE="prometheus"

# Eliminar Prometheus si existe
if helm ls -n "$NAMESPACE" | grep -q prometheus; then
  echo "🗑 Eliminando Prometheus..."
  helm uninstall prometheus -n "$NAMESPACE"
else
  echo "⚠️ Prometheus ya estaba eliminado."
fi

# Asegurar que el namespace no existe
if kubectl get namespace "$NAMESPACE" &>/dev/null; then
  echo "🗑 Eliminando namespace $NAMESPACE..."
  kubectl delete namespace "$NAMESPACE"
else
  echo "⚠️ Namespace $NAMESPACE ya estaba eliminado."
fi

# Crear namespace
kubectl create namespace "$NAMESPACE"

# Instalar Prometheus sin almacenamiento persistente
helm install prometheus prometheus-community/prometheus \
  --namespace "$NAMESPACE" \
  --set alertmanager.persistentVolume.enabled=true \
  --set server.persistentVolume.enabled=true

echo "✅ Instalación de Prometheus completada."