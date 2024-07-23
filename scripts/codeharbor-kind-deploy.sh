#!/bin/bash

scp k8s/kind-config.yaml k8s/codeharbor.yaml debian@instance-ip:~

# Define relative paths
KIND_CONFIG="/home/debian/kind-config.yaml"
DEPLOYMENT_FILE="/home/debian/codeharbor.yaml"

CLUSTER_NAME="codeharbor"

# Creating kind cluster
echo "Creating the Kind cluster..."
ssh debian@instance-ip "kind create cluster --name $CLUSTER_NAME --config=$KIND_CONFIG"

# Check if the Kind cluster was created and set as the current context
echo "Checking if kubectl is configured to use the Kind cluster..."
ssh debian@instance-ip "kubectl cluster-info --context kind-$CLUSTER_NAME"

if [ $? -eq 0 ]; then
    echo "Kind cluster is ready. Deploying application..."
    
    # Applying deployment file
    ssh debian@instance-ip "kubectl apply -f $DEPLOYMENT_FILE"
    
    echo "Application deployed successfully."
else
    echo "Failed to configure kubectl for Kind cluster."
fi