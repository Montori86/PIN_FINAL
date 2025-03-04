#!/bin/bash

# Obtener el hostname del LoadBalancer de Grafana
ELB=$(kubectl get svc -n grafana grafana -o jsonpath='{.status.loadBalancer.ingress[0].hostname}')

# Verificar si se obtuvo un resultado válido
if [[ -z "$ELB" ]]; then
    echo "⚠️  No se pudo obtener el hostname de Grafana. Puede que el LoadBalancer aún esté aprovisionando."
    exit 1
fi

# Obtener la contraseña del usuario admin
ADMIN_PASSWORD=$(kubectl get secret --namespace grafana grafana -o jsonpath="{.data.admin-password}" | base64 --decode)

# Mostrar la URL de acceso y la contraseña de Grafana
echo "🔗 URL de Grafana: http://$ELB"
echo "🔑 Contraseña de admin: $ADMIN_PASSWORD"
