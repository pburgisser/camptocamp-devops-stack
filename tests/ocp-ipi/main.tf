# terraform/main.tf

locals {
  cluster_name = terraform.workspace
}


module "argocd" {
  source = "../../modules/openshift4/ipi"

  cluster_name = terraform.workspace
  

  base_domain     = "https://console-openshift-console.apps.ocppbu43.labs.camptocamp.com"
  cluster_issuer  = "https://ocptest.auth.eu-west-1.amazoncognito.com"
#  cognito_user_pool_id     = aws_cognito_user_pool.pool.id
#  cognito_user_pool_domain = aws_cognito_user_pool_domain.pool_domain.domain
}

#resource "aws_cognito_user_pool" "pool" {
#  name = "pool"
#}

#resource "aws_cognito_user_pool_domain" "pool_domain" {
#  domain       = "pool-domain"
#  user_pool_id = aws_cognito_user_pool.pool.id
#}