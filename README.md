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

Before deploying our Kubernetes configurations, we prepared our environment with necessary tools including Docker, `kubectl`, and a local Kubernetes cluster using `kind`. The `kind` tool allows us to run Kubernetes locally for testing purposes.

### Installing `kubectl`

The `kubectl` command-line tool allows you to run commands against Kubernetes clusters, making it essential for managing your Kubernetes applications. Here's how to install `kubectl` on various operating systems:

1.  **Download the Latest Version Using Curl**:

    ```bash
    curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
    ```

2.  **Make the kubectl Binary Executable**:

    `chmod +x ./kubectl`
    
3.  **Move the Binary in Your PATH**:

    `sudo mv ./kubectl /usr/local/bin/kubectl`

4.  **Test to Ensure the Version is Up-to-Date**:

    `kubectl version --client`

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

### Transferring Configuration Files and Scripts

First, we need to transfer our local configuration files and scripts to the OVH instance. This is done using the `scp` command, ensuring that our Kubernetes configurations and the deployment script are available on the remote server.

```bash
scp scripts/codeharbor-kind-deploy.sh k8s/kind-config.yaml k8s/codeharbor.yaml debian@57.128.61.186:~
```

### Remote Execution of the Deployment Script

Once the necessary files are on the OVH instance, we execute the deployment script. This script is responsible for creating the Kubernetes cluster using `kind`, applying the Kubernetes configurations, and ensuring that our application is deployed and managed by Kubernetes.

To execute the script remotely, we use the `ssh` command to run the script directly on the OVH instance:

```bash
`ssh debian@57.128.61.186 "bash ~/codeharbor-kind-deploy.sh"`
```

```bash
sudo usermod -aG docker debian
```

### Local Script for Remote Execution (Optional)

For convenience, we can also use a local script named `execute-remote.sh` to automate the SSH connection and script execution process. This script encapsulates the `ssh` command, making the deployment process even smoother.

To run this script, ensure it is executable and then execute it from your local machine:

```bash
`chmod +x execute-remote.sh ./execute-remote.sh`
```

Conclusion
----------

The CodeHarbor project showcases a practical implementation of using Docker, Kubernetes, Terraform, and GitHub Actions to automate the deployment of containerized applications. Through this project, we've demonstrated how to prepare a local Kubernetes environment, automate the build and deployment process, and utilize IaC principles for efficient and scalable application management.