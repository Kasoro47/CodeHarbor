CodeHarbor Project README
=========================

Overview
--------

The CodeHarbor project focuses on deploying and managing containerized services within a Kubernetes cluster. This project demonstrates how to automate the deployment process using Bash for Kubernetes configurations and Docker for containerization, ensuring an efficient and reproducible application deployment.

Key Components
--------------

*   **Docker**: Used for creating a containerized version of our application.

*   **Kubernetes**: The target platform for deploying our containerized application.

*   **GitHub Actions**: Automates the CI/CD pipeline, including building Docker images and applying Kubernetes configurations using Bash.

*  **Helm**: A package manager for Kubernetes that simplifies the deployment of applications and services to a Kubernetes cluster.

*   **Kind**: A tool for running local Kubernetes clusters using Docker container nodes.

*   **MetalLB**: A load balancer for Kubernetes that provides network load balancing to expose services within the cluster.

*   **Prometheus and Grafana**: Monitoring tools for tracking the performance of the application.

Initial Setup
-------------

Before deploying our Kubernetes configurations, I prepared the environment with necessary tools including Docker, `kubectl`, and a local Kubernetes cluster using `kind`. The `kind` tool allows us to run Kubernetes.

### Installing `kubectl`

The `kubectl` command-line tool allows you to run commands against Kubernetes clusters, making it essential for managing your Kubernetes applications. Here's how to install `kubectl` on various operating systems:

1.  **Download the Latest Version Using Curl**:

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```

2.  **Make the kubectl Binary Executable**:

    ```bash
    chmod +x ./kubectl
    ```

3.  **Move the Binary in Your PATH**:

    ```bash
    sudo mv ./kubectl /usr/local/bin/kubectl
    ```

4.  **Test to Ensure the Version is Up-to-Date**:

    ```bash
    kubectl version --client
    ```

### Installing `kind`

I chose `kind` (Kubernetes IN Docker) for creating the local Kubernetes cluster due to its simplicity and the minimal setup required. The installation steps are as follows:

1.  Download the `kind` binary suitable for our system architecture. For 64-bit Linux systems, the command is:

    ```bash
    [ $(uname -m) = x86_64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.22.0/kind-linux-amd64
    ```

3.  Allow the kind binary to be executed:

    ```bash
    chmod +x ./kind
    ```

2.  Move the downloaded binary to `/usr/local/bin` to make it available system-wide:

    ```bash
    sudo mv ./kind /usr/local/bin/kind
    ```

This makes `kind` accessible from anywhere on the system, allowing us to create and manage local Kubernetes clusters.

### Installing Docker

Docker is a critical component for running containerized applications, including the local Kubernetes cluster I'm setting up with `kind`. Here's a step-by-step guide to installing Docker on your system.

1.  **Update Your System**: Before installing Docker, it's always a good practice to update your system's package index. Execute the following command to do so:

    ```bash
    sudo apt-get update
    ```

2.  **Install Docker**:

    Install the Docker's official GPG key and add the Docker's repository to Apt sources:

    ```bash
    # Add Docker's official GPG key:
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc

    # Add the repository to Apt sources:
    echo \
    "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
    $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
    sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ```

    Then install Docker's package

    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
    ```

3.  **Verify Docker Installation**:

    To verify that Docker has been installed correctly and that you can run Docker commands without `sudo`, add your user to the `docker` group and relog or reboot:

    ```bash
    sudo usermod -aG docker $USER
    ```

    Then, log out and back in for this to take effect, or you can run the following command to activate the changes to groups:

    ```bash
    newgrp docker
    ```

    After this, you can test your Docker installation by running:

    ```bash
    docker run hello-world
    ```

    This command downloads a test image and runs it in a container. If the container runs successfully, it prints an informational message and exits. If you see the message, it confirms that Docker is installed and working correctly.

Project Structure
-----------------

**Dockerfile**: Contains the Docker configuration to build our application's container image.

**kind-config.yaml**: Configuration file for creating the Kind Kubernetes cluster.

* **codeharbor**: Helm chart for deploying the main application.
Chart.yaml**: Defines the chart and its metadata.
    - **templates**: Contains Kubernetes manifests for the application.
    - **values.yaml**: Default configuration values for the chart.
    - **Chart.yaml**: Defines the chart and its metadata.
* **metallb**: Helm chart for MetalLB, used for load balancing services in the Kubernetes cluster.
    - **Chart.yaml**: Defines the chart and its metadata.
    - **templates**: Contains Kubernetes manifests for MetalLB.
    - **values.yaml**: Default configuration values for the chart.
* **monitoring**: Helm chart for monitoring tools like Prometheus and Grafana.
    - **Chart.yaml**: Defines the chart and its metadata.
    - **templates**: Contains Kubernetes manifests for monitoring tools.
    - **values.yaml**: Default configuration values for the chart.
* **nginx-ingress**: Helm chart for NGINX Ingress Controller.
    - **Chart.yaml**: Defines the chart and its metadata.
    - **templates**: Contains Kubernetes manifests for NGINX Ingress Controller.
    - **values.yaml**: Configuration values for the chart.

**scripts/codeharbor-kind-deploy.sh**: Script to deploy the Kubernetes cluster and application.

**.github/workflows/action.yaml**: CI/CD pipeline configuration using GitHub Actions. It automates the process of building the Docker image, pushing it to a registry, and applying the Kubernetes deployment using the Bash script.

Deployment Process
------------------

1.  **Build and Push Docker Image**: The GitHub Actions workflow defined in `.github/workflows/action.yaml` automates the process of building a Docker image from the Dockerfile and pushing it to a Docker registry. It uses the commit SHA as a tag for each image to ensure version control.

2.  **Applying Kubernetes Configurations**: After the Docker image is pushed to the registry, the same workflow uses `kubectl` to apply the Kubernetes configurations defined in `charts/kind-config.yaml`. This step is crucial for deploying the application to the Kubernetes cluster.

3.  **Monitoring Setup**: The monitoring setup includes deploying Prometheus and Grafana to monitor the application's performance. The configurations for Prometheus and Grafana are defined in `charts/monitoring`.

4.  **Nginx Ingress Controller**: The Nginx Ingress Controller is used to manage external access to services running within the Kubernetes cluster. The configurations for the Nginx Ingress Controller are defined in `charts/nginx-ingress`.

5.  **MetalLB Configuration**: MetalLB is a load balancer that provides network load balancing to expose services within the Kubernetes cluster. The configuration for MetalLB is defined in `charts/metallb`.

Automating Kubernetes Cluster Deployment Remotely
-------------------------------------------------

To execute the script remotely, I use this command to run it from my computer:

```bash
scripts/codeharbor-kind-deploy.sh
```

This script automates the entire process of deploying a Kubernetes cluster using Kind on a remote Debian server, and then deploying a specified application to this cluster.

Accessing server from a Remote Computer
----------------------------------------

#### Ensure External IP is Assigned:

Check the external IP assigned to the nginx-ingress service by running:

```bash
kubectl get svc
```

Copy the internal IP address of the service where the service is running.

If you want to access the web server securely from a remote computer, you can create an SSH tunnel:

#### Create SSH Tunnel:

Run the following command on your remote computer to create an SSH tunnel to access the web server:

```bash
ssh -L 8080:172.18.0.101:80 debian@instance-ip
```

This command forwards port 8080 on your local machine to port 80 on the Kubernetes node.

If you want to access Grafana the same way:

```bash
ssh -L 3000:172.18.0.2:32000 debian@instance-ip
```

#### Access the Web Server:

Open a web browser on your remote computer and navigate to:

```bash
http://localhost:8080
```

Conclusion
----------

The CodeHarbor project showcases a practical implementation of using Docker and Kubernetes to automate the deployment of containerized applications. Through this project, I've demonstrated how to prepare a local Kubernetes environment and automate the build and deployment process.
