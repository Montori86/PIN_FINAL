# Guía de instalación de Prometheus sin almacenamiento persistente

Este documento detalla los pasos para instalar Prometheus en un clúster Kubernetes sin almacenamiento persistente.

## Eliminar cualquier instalación previa de Prometheus

Primero, eliminamos cualquier instalación previa de Prometheus con los siguientes comandos:

```bash
helm uninstall prometheus -n prometheus
kubectl delete namespace prometheus
```

## Reinstalar Prometheus sin almacenamiento persistente

Ahora, reinstalamos Prometheus sin almacenamiento persistente usando Helm:

```bash
helm install prometheus prometheus-community/kube-prometheus-stack --namespace prometheus --create-namespace --set prometheus.persistence.enabled=false
```

### ¿Por qué no usamos PVC?

Usamos `--set prometheus.persistence.enabled=false` para deshabilitar la persistencia de datos de Prometheus. Esto significa que los datos no se guardarán en un volumen persistente, lo que puede ser útil en entornos de prueba o desarrollo donde no se requiere retención de datos a largo plazo. Además, esto facilita la instalación y el despliegue rápido sin necesidad de configurar almacenamiento adicional.

## Verificar que los pods están corriendo

Verificamos que los pods de Prometheus estén corriendo correctamente con el siguiente comando:

```bash
kubectl get pods -n prometheus
```

## Revisar los servicios expuestos

Revisamos los servicios expuestos en el namespace de Prometheus para asegurarnos de que Prometheus está accesible:

```bash
kubectl get svc -n prometheus
```

## Hacer un port-forward del pod Prometheus-server al puerto 8080 local

Para acceder a Prometheus desde el navegador, realizamos un port-forward del pod `prometheus-server` al puerto local 8080:

```bash
kubectl port-forward svc/prometheus-server -n prometheus 8080:80
```

## Probar el acceso a Prometheus

Por último, probamos el acceso a Prometheus en nuestro navegador en la siguiente URL:

[http://localhost:8080](http://localhost:8080)

¡Con esto, ya deberíamos tener acceso a la interfaz web de Prometheus!
