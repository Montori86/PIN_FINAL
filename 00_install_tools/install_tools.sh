#!/bin/bash

# Instalar unzip si no está instalado
echo "Installing unzip"
sudo apt install -y unzip

################ Esta seccion no es necesaria, debido a que ya está instalado aws en el host ################

# # Instalar AWS CLI
# echo "Installing AWS CLI"
# curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
# unzip awscliv2.zip
# sudo ./aws/install --update
# aws --version
# echo "AWS CLI installed successfully"

################# 

# Instalación de kubectl
echo "Installing kubectl"
curl -o kubectl https://s3.us-west-2.amazonaws.com/amazon-eks/1.26.2/2023-03-17/bin/linux/amd64/kubectl
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl
kubectl version --client
echo "kubectl installed successfully"


# Instalación de eksctl
echo "Installing eksctl"
curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
if [ $? -ne 0 ]; then
  echo "Failed to download eksctl"
  exit 1
fi
sudo mv /tmp/eksctl /usr/local/bin
if [ $? -ne 0 ]; then
  echo "Failed to move eksctl to /usr/local/bin"
  exit 1
fi
export PATH=$PATH:/usr/local/bin
echo 'export PATH=$PATH:/usr/local/bin' >> ~/.bashrc
eksctl version

# Instalación de Docker
echo "Installing Docker"
sudo apt install -y docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

# Añadir el usuario al grupo docker para que pueda usar Docker sin sudo
sudo usermod -aG docker ec2-user
newgrp docker

# Descargar e instalar Docker Compose
echo "Installing Docker Compose"
wget https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)
sudo mv docker-compose-$(uname -s)-$(uname -m) /usr/local/bin/docker-compose
sudo chmod -v +x /usr/local/bin/docker-compose

echo "Installing Helm"
curl https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3 | bash
helm version

# Instalación de Terraform
echo "Installing Terraform"

# Descargar e instalar Terraform desde HashiCorp
echo "Descargando Terraform..."
curl -fsSL https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip -o terraform_1.5.0_linux_amd64.zip

# Descomprimir el archivo descargado
echo "Descomprimiendo Terraform..."
unzip terraform_1.5.0_linux_amd64.zip

# Mover el binario de Terraform a una ubicación global
echo "Moviendo Terraform a /usr/local/bin..."
sudo mv terraform /usr/local/bin/

# Verificar que Terraform está instalado correctamente
terraform --version

echo "Instalación de Terraform completada"

echo "Instalación completada"
