locals {
  base_domain                       = var.base_domain
  kubernetes_host                   = "api.ocppbu43.labs.camptocamp.com:6443"
  #kubernetes_cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority.0.data)
  #kubernetes_token                  = data.aws_eks_cluster_auth.cluster.token
  kubeconfig                        = file("/home/pburgisser/git/pbuocp44/auth/kubeconfig")
}

provider "kubernetes" {
  config_path = "/home/pburgisser/git/pbuocp44/auth/kubeconfig"
}

provider "helm" {
  kubernetes {
    config_path = "/home/pburgisser/git/pbuocp44/auth/kubeconfig"
  }
}

module "argocd" {
  source = "../../argocd-helm"
  kubeconfig      = local.kubeconfig
  repo_url        = var.repo_url
  target_revision = var.target_revision
  extra_apps      = var.extra_apps
  cluster_name    = var.cluster_name
  base_domain     = var.base_domain
  cluster_issuer  = "letsencrypt-prod"
  minio = {
    enabled = false
  }
  loki = {
    enabled = false
  }
  efs_provisioner = {
    enabled = false
  }

  keycloak = {
    enabled = false
  }
  grafana = {
    enabled = false
  }
  prometheus = {
    enabled = false
  }
  alertmanager = {
    enabled = false
  }
  metrics_archives = {
    enabled = false
  }
  oidc = {}

}
