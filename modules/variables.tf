variable "cluster_name" {
  description = "The name of the Kubernetes cluster to create."
  type        = string
}

variable "repo_url" {
  description = "The source repo URL of ArgoCD's app of apps."
  type        = string
  default     = "https://github.com/camptocamp/camptocamp-devops-stack.git"
}

variable "target_revision" {
  description = "The source target revision of ArgoCD's app of apps."
  type        = string
  default     = "v0.28.0"
}

variable "app_of_apps_values_overrides" {
  description = "App of apps values overrides."
  type        = string
  default     = ""
}

variable "extra_apps" {
  description = "Extra applications to deploy."
  type        = list(any)
  default     = []
}

variable "base_domain" {
  description = "The base domain used for Ingresses."
  type        = string
}

variable "cluster_issuer" {
  description = "Cluster Issuer"
  type        = string
}