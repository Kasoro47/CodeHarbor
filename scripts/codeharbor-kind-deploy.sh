#!/bin/bash

# Copy configuration files to the Debian instance
scp k8s/kind-config.yaml k8s/codeharbor.yaml k8s/network/network-policy.yaml monitoring/prometheus-config.yaml monitoring/prometheus-deployment.yaml monitoring/grafana-deployment.yaml monitoring/ipaddresspool.yaml monitoring/l2advertisement.yaml debian@57.128.61.186:~

# Define relative paths on the remote server
KIND_CONFIG="/home/debian/kind-config.yaml"
DEPLOYMENT_FILE="/home/debian/codeharbor.yaml"
NETWORK_POLICY_FILE="/home/debian/network-policy.yaml"
PROMETHEUS_CONFIG="/home/debian/prometheus-config.yaml"
PROMETHEUS_DEPLOYMENT="/home/debian/prometheus-deployment.yaml"
GRAFANA_DEPLOYMENT="/home/debian/grafana-deployment.yaml"
METALLB_IP_POOL="/home/debian/ipaddresspool.yaml"
METALLB_L2_ADVERTISEMENT="/home/debian/l2advertisement.yaml"

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
    
    # Create Docker registry secret
    ssh debian@57.128.61.186 "kubectl create secret docker-registry ghcr-credentials \
      --docker-server=ghcr.io \
      --docker-username=kasoro \
      --docker-password=$DOCKER_PASSWORD"

    # Create a namespace for monitoring
    ssh debian@57.128.61.186 "kubectl create namespace monitoring"

    # Apply deployment file
    ssh debian@57.128.61.186 "kubectl apply -f $DEPLOYMENT_FILE"

    # Apply network policy
    ssh debian@57.128.61.186 "kubectl apply -f $NETWORK_POLICY_FILE"

    # Apply Prometheus configuration
    ssh debian@57.128.61.186 "kubectl apply -f $PROMETHEUS_CONFIG"

    # Deploy Prometheus
    ssh debian@57.128.61.186 "kubectl apply -f $PROMETHEUS_DEPLOYMENT"

    # Deploy Grafana
    ssh debian@57.128.61.186 "kubectl apply -f $GRAFANA_DEPLOYMENT"

    # Deploy MetalLB
    ssh debian@57.128.61.186 << EOF
      kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
EOF

    # Wait for MetalLB webhook service to be ready
    echo "Waiting for MetalLB webhook service to be ready..."
    until ssh debian@57.128.61.186 "kubectl get svc metallb-webhook-service -n metallb-system"; do
      echo "Waiting for metallb-webhook-service to be created..."
      sleep 5
    done

    # Ensure the webhook service is fully operational
    sleep 30

    # Apply MetalLB configurations
    ssh debian@57.128.61.186 "kubectl apply -f $METALLB_IP_POOL"
    ssh debian@57.128.61.186 "kubectl apply -f $METALLB_L2_ADVERTISEMENT"

    echo "Application deployed successfully."
else
    echo "Failed to configure kubectl for Kind cluster."
fi
