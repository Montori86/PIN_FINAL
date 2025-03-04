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

# Función para ejecutar un script y verificar si falla
run_script() {
    local script_name=$1
    echo "🔹 Ejecutando $script_name..."
    bash "$script_name" || error_exit "Falló la ejecución de $script_name"
}

# Ejecutar los scripts en orden
run_script "$PROMETHEUS_SCRIPT"
run_script "$GRAFANA_SCRIPT"

echo "✅ ¡Despliegue completado exitosamente!"
