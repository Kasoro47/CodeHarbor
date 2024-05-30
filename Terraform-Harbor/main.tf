terraform {
  required_providers {
    ovh = {
      source  = "ovh/ovh"
    }
  }
}

provider "ovh" {
  endpoint           = "ovh-eu"
  application_key    = "<your_access_key>"
  application_secret = "<your_application_secret>"
  consumer_key       = "<your_consumer_key>"
}

# Kubernetes deployment
resource "kubernetes_deployment" "code-harbor" {
  metadata {
    name = "code-harbor"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "code-harbor"
      }
    }
    template {
      metadata {
        labels = {
          app = "code-harbor"
        }
      }
      spec {
        container {
          image = "ghcr.io/kasoro47/my-nginx:v1"
          name  = "code-harbor"
        }
        image_pull_secrets {
          name = "ghcr-credentials"
        }
      }
    }
  }
}
