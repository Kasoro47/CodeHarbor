terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

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

