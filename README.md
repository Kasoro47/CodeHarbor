CodeHarbor Project README
=========================

Overview
--------

The CodeHarbor project focuses on leveraging Infrastructure as Code (IaC) to deploy and manage containerized services within a Kubernetes cluster. This project demonstrates how to automate the deployment process using Terraform for Kubernetes configurations and Docker for containerization, ensuring an efficient, reproducible, and scalable application deployment.

Key Components
--------------

*   **Docker**: Used for creating a containerized version of our application.
*   **Kubernetes**: The target platform for deploying our containerized application.
*   **Terraform**: Utilized for automating the deployment of Kubernetes configurations.
*   **GitHub Actions**: Automates the CI/CD pipeline, including building Docker images and applying Kubernetes configurations using Terraform.

Initial Setup
-------------

Before deploying our Kubernetes configurations, we prepared our environment with necessary tools including Docker, `kubectl`, and a local Kubernetes cluster using `kind`. The `kind` tool allows us to run Kubernetes.

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

We chose `kind` (Kubernetes IN Docker) for creating our local Kubernetes cluster due to its simplicity and the minimal setup required. The installation steps are as follows:

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

Docker is a critical component for running containerized applications, including the local Kubernetes cluster we're setting up with `kind`. Here's a step-by-step guide to installing Docker on your system.

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

*   **Dockerfile**: Contains the Docker configuration to build our application's container image.
*   **k8s/codeharbor.yaml**: Kubernetes deployment configuration that defines how our application is deployed within the cluster.
*   **Terraform-Harbor/main.tf**: Terraform configuration that manages the Kubernetes deployment defined in `k8s/codeharbor.yaml`.
*   **.github/workflows/terraform.yaml**: CI/CD pipeline configuration using GitHub Actions. It automates the process of building the Docker image, pushing it to a registry, and applying the Kubernetes deployment using Terraform.

Deployment Process
------------------

1.  **Build and Push Docker Image**: The GitHub Actions workflow defined in `.github/workflows/terraform.yaml` automates the process of building a Docker image from the Dockerfile and pushing it to a Docker registry. It uses the commit SHA as a tag for each image to ensure version control.

2.  **Applying Kubernetes Configurations**: After the Docker image is pushed to the registry, the same workflow uses `kubectl` to apply the Kubernetes configurations defined in `k8s/codeharbor.yaml`. This step is crucial for deploying the application to the Kubernetes cluster.

3.  **Terraform Deployment**: Initially, the plan was to use Terraform for applying Kubernetes configurations. The `Terraform-Harbor/main.tf` file contains the Terraform setup necessary for deploying the application defined in the Kubernetes YAML configuration. However, this approach requires careful management of Terraform state files and an understanding of how Terraform interacts with Kubernetes resources.

Deployment Automation
---------------------

To fully automate the deployment of our application within a Kubernetes cluster on an OVH instance, we leverage scripts and configuration files. This section outlines the commands and processes involved in deploying our application, ensuring that all necessary components and configurations are correctly applied to the remote environment.

### Automating Kubernetes Cluster Deployment Remotely

To execute the script remotely, we use this command to run it from our computer:

```bash
scripts/codeharbor-kind-deploy.sh
```

This script automates the entire process of deploying a Kubernetes cluster using Kind on a remote Debian server, and then deploying a specified application to this cluster.

Conclusion
----------

The CodeHarbor project showcases a practical implementation of using Docker, Kubernetes, Terraform, and GitHub Actions to automate the deployment of containerized applications. Through this project, we've demonstrated how to prepare a local Kubernetes environment, automate the build and deployment process, and utilize IaC principles for efficient and scalable application management.
