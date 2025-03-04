#!/bin/bash

# Obtener el hostname del LoadBalancer de Grafana
ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Verificar si se obtuvo un resultado válido
if [[ -z "$ELB" ]]; then
    echo "⚠️  No se pudo obtener el hostname de Grafana. Puede que el LoadBalancer aún esté aprovisionando."
    exit 1
fi

# Mostrar la URL de acceso a Grafana
echo "🔗 URL de Grafana: http://$ELB"
