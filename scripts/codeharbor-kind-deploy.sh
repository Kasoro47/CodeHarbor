#!/bin/bash

# Copy configuration files to the Debian instance
scp -r charts/ debian@57.128.61.186:~
scp charts/kind-config.yaml debian@57.128.61.186:~
scp scripts/codeharbor-kind-deploy.sh debian@57.128.61.186:~

# Define relative paths on the remote server
CHARTS_DIR="/home/debian/charts"
KIND_CONFIG="/home/debian/charts/kind-config.yaml"

CLUSTER_NAME="codeharbor"
DOCKER_PASSWORD=$(pass docker)

# Creating kind cluster
echo "Creating the Kind cluster..."
ssh debian@57.128.61.186 "kind create cluster --name $CLUSTER_NAME --config=$KIND_CONFIG"

# Check if the Kind cluster was created and set as the current context
echo "Checking if kubectl is configured to use the Kind cluster..."
ssh debian@57.128.61.186 "kubectl cluster-info --context kind-$CLUSTER_NAME"

if [ $? -eq 0 ]; then
    echo "Kind cluster is ready. Deploying application..."

    # Install Helm
    ssh debian@57.128.61.186 "curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash"

    # Add MetalLB Helm repository
    ssh debian@57.128.61.186 "helm repo add metallb https://metallb.github.io/metallb"

    # Update Helm repositories
    ssh debian@57.128.61.186 "helm repo update"

    # Create Docker registry secret
    ssh debian@57.128.61.186 "kubectl create secret docker-registry ghcr-credentials \
      --docker-server=ghcr.io \
      --docker-username=kasoro \
      --docker-password=$DOCKER_PASSWORD"

    # Create namespaces
    ssh debian@57.128.61.186 "kubectl create namespace monitoring"
    ssh debian@57.128.61.186 "kubectl create namespace metallb-system"

    # Deploy MetalLB
    ssh debian@57.128.61.186 << EOF
          kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
EOF

    # Install MetalLB CRDs
    ssh debian@57.128.61.186 "kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/config/crd/bases/metallb.io_ipaddresspools.yaml"
    ssh debian@57.128.61.186 "kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/main/config/crd/bases/metallb.io_l2advertisements.yaml"

    # Wait for CRDs to be applied
    echo "Waiting for MetalLB CRDs to be applied..."
    sleep 20

    # Deploy MetalLB using Helm
    ssh debian@57.128.61.186 "helm install metallb $CHARTS_DIR/metallb --namespace metallb-system"

    # Deploy NGINX Ingress Controller using Helm
    ssh debian@57.128.61.186 "helm install nginx-ingress $CHARTS_DIR/nginx-ingress"

    # Deploy codeharbor using Helm
    ssh debian@57.128.61.186 "helm install codeharbor $CHARTS_DIR/codeharbor"

    # Deploy monitoring using Helm
    ssh debian@57.128.61.186 "helm install monitoring $CHARTS_DIR/monitoring --namespace monitoring"

    echo "Application deployed successfully."
else
    echo "Failed to configure kubectl for Kind cluster."
fi
