#!/bin/bash

# Obtener la ruta donde está el script actual
SCRIPT_DIR=$(dirname "$0")

# Definir rutas de los scripts a ejecutar
PROMETHEUS_SCRIPT="$SCRIPT_DIR/prometheus-deploy.sh"
GRAFANA_SCRIPT="$SCRIPT_DIR/grafana-deploy.sh"

# Función para mostrar mensajes de error y salir
function error_exit {
    echo "❌ Error: $1"
    exit 1
}

# Función para eliminar un release de Helm solo si está instalado
delete_helm_release() {
    local release_name=$1
    local namespace=$2

    if helm list -n "$namespace" | grep -q "$release_name"; then
        helm uninstall "$release_name" -n "$namespace"
        echo "✅ $release_name eliminado."
    else
        echo "⚠️ $release_name ya estaba eliminado."
    fi
}

# Función para eliminar todo completamente
clean_up() {
    echo "🗑 Eliminando Prometheus y Grafana..."

    # Eliminar los releases de Helm
    delete_helm_release prometheus prometheus
    delete_helm_release grafana grafana

    # Eliminar todos los recursos en los namespaces (pods, servicios, deployments, etc.)
    kubectl delete all --all -n prometheus --ignore-not-found=true
    kubectl delete all --all -n grafana --ignore-not-found=true

    # Eliminar volúmenes persistentes (PVCs) si quedaron
    kubectl delete pvc --all -n prometheus --ignore-not-found=true
    kubectl delete pvc --all -n grafana --ignore-not-found=true

    # Eliminar ConfigMaps y Secrets en caso de que hayan quedado
    kubectl delete configmap --all -n prometheus --ignore-not-found=true
    kubectl delete configmap --all -n grafana --ignore-not-found=true
    kubectl delete secret --all -n prometheus --ignore-not-found=true
    kubectl delete secret --all -n grafana --ignore-not-found=true

    # Eliminar servicios tipo LoadBalancer (para no dejar instancias en AWS)
    kubectl delete svc --all -n prometheus --ignore-not-found=true
    kubectl delete svc --all -n grafana --ignore-not-found=true

    # Finalmente, eliminar los namespaces
    kubectl delete namespace prometheus --ignore-not-found=true
    kubectl delete namespace grafana --ignore-not-found=true

    echo "✅ Todo eliminado correctamente. No quedan recursos que generen costos en AWS."
    exit 0
}

# Verificar si se pasó el argumento --delete
if [[ "$1" == "--delete" ]]; then
    clean_up
fi

# Si no se pasó --delete, ejecutar los despliegues
run_script() {
    local script_name=$1
    echo "🔹 Ejecutando $script_name..."
    bash "$script_name" || error_exit "Falló la ejecución de $script_name"
}

run_script "$PROMETHEUS_SCRIPT"
run_script "$GRAFANA_SCRIPT"

echo "✅ ¡Despliegue completado exitosamente!"
