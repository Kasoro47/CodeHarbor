#!/bin/bash

scp scripts/codeharbor-kind-deploy.sh k8s/kind-config.yaml k8s/codeharbor.yaml debian@57.128.61.186:~

# Define relative paths
KIND_CONFIG="/home/debian/kind-config.yaml"
DEPLOYMENT_FILE="/home/debian/codeharbor.yaml"

CLUSTER_NAME="codeharbor"

# Creating kind cluster
echo "Creating the Kind cluster..."
ssh debian@57.128.61.186 "kind create cluster --name $CLUSTER_NAME --config=$KIND_CONFIG"

# Check if the Kind cluster was created and set as the current context
echo "Checking if kubectl is configured to use the Kind cluster..."
ssh debian@57.128.61.186 "kubectl cluster-info --context kind-$CLUSTER_NAME"

if [ $? -eq 0 ]; then
    echo "Kind cluster is ready. Deploying application..."
    
    # Applying deployment file
    ssh debian@57.128.61.186 "kubectl apply -f $DEPLOYMENT_FILE"
    
    echo "Application deployed successfully."
else
    echo "Failed to configure kubectl for Kind cluster."
fi