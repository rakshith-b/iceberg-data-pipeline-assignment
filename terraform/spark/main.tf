terraform {
  required_version = ">= 1.3.0"
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = ">= 2.7.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.13.1"
    }
  }
}

provider "kubernetes" {
  host                   = var.kubernetes_host
  cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
  token                  = var.kubernetes_token
}

provider "helm" {
  kubernetes {
    host                   = var.kubernetes_host
    cluster_ca_certificate = base64decode(var.kubernetes_cluster_ca_certificate)
    token                  = var.kubernetes_token
  }
}

resource "helm_release" "spark" {
  name       = "spark"
  namespace  = var.spark_namespace
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "spark"
  version    = var.spark_chart_version

  create_namespace = true

  values = [
    file("${path.module}/spark-values.yaml")
  ]
}  
