#!/bin/bash
# Instalar Prometheus y Grafana usnado Helm (Manejador de paquetes para kubernetes)

# Agregar repo de prometheus
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

# Agregar repo de grafana
helm repo add grafana https://grafana.github.io/helm-charts

helm repo update
# Crear el namespace prometheus
kubectl create namespace prometheus

# Desplegar prometheus en EKS
helm install prometheus prometheus-community/prometheus \
--namespace prometheus \
--set alertmanager.persistentVolume.storageClass="gp3" \
--set server.persistentVolume.storageClass="gp3" 

# NOTE: El cambio de storageclass de gp2 a gp3 se debe a que los nodos del clúster EKS ya están usando volúmenes gp3, 
# por lo que es mejor mantener coherencia en todo el stack. gp3 ofrece mejor rendimiento y 
# menor costo en comparación con gp2, sin depender del tamaño del volumen para IOPS y throughput.
# Evitamos posibles problemas si la StorageClass gp2 no está disponible en el clúster, así garantizamos que tanto 
# Prometheus como los nodos usen la misma tecnología de almacenamiento.

# Verificar la instalación
kubectl get all -n prometheus

# Exponer prometheus en la instancia de EC2 en el puerto 8080
kubectl port-forward -n prometheus deploy/prometheus-server 8080:9090 --address 0.0.0.0
