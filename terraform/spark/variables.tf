variable "kubernetes_host" {
  description = "The Kubernetes API server host"
  type        = string
}

variable "kubernetes_cluster_ca_certificate" {
  description = "The Kubernetes cluster CA certificate (base64 encoded)"
  type        = string
}

variable "kubernetes_token" {
  description = "The token for accessing the Kubernetes API"
  type        = string
  sensitive   = true
}

variable "spark_namespace" {
  description = "Namespace to deploy Spark into"
  type        = string
  default     = "spark"
}

variable "spark_chart_version" {
  description = "Version of the Bitnami Spark chart"
  type        = string
  default     = "8.1.4"
}
