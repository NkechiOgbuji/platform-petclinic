data "aws_caller_identity" "current" {}

data "aws_partition" "current" {}

locals {
  name_prefix            = "${var.project_name}-${var.environment}"
  cluster_name           = "${local.name_prefix}-eks"
  argocd_domain_name     = "${var.argocd_subdomain}.${var.root_domain_name}"
  grafana_domain_name    = "${var.grafana_subdomain}.${var.root_domain_name}"
  prometheus_domain_name = "${var.prometheus_subdomain}.${var.root_domain_name}"
  github_actions_role_arn = trimspace(var.github_actions_role_arn) != "" ? trimspace(var.github_actions_role_arn) : (
    "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:role/${var.github_actions_role_name}"
  )

  common_tags = {
    Project     = var.project_name
    Environment = var.environment
  }
}

module "vpc" {
  source = "../../modules/vpc"

  environment        = var.environment
  vpc_cidr           = var.vpc_cidr
  availability_zones = var.availability_zones
  cluster_name       = local.cluster_name
}

module "ecr" {
  source = "../../modules/ecr"

  environment       = var.environment
  repository_prefix = var.repository_prefix
  tags              = local.common_tags
}

module "observability" {
  source = "../../modules/observability"

  project_name = var.project_name
  environment  = var.environment
  aws_region   = var.aws_region
  tags         = local.common_tags
}

module "eks" {
  source = "../../modules/eks"

  cluster_name               = local.cluster_name
  project_name               = var.project_name
  environment                = var.environment
  cluster_version            = var.cluster_version
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  cluster_security_group_ids = [module.vpc.eks_cluster_security_group_id]
  endpoint_public_access     = var.eks_endpoint_public_access
  endpoint_private_access    = var.eks_endpoint_private_access
  node_instance_types        = var.eks_node_instance_types
  node_desired_size          = var.eks_node_desired_size
  node_min_size              = var.eks_node_min_size
  node_max_size              = var.eks_node_max_size
  github_actions_role_arn    = local.github_actions_role_arn
  admin_role_arns            = var.eks_admin_role_arns
  tags                       = local.common_tags
}

module "rds" {
  source = "../../modules/rds"

  environment                = var.environment
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = module.vpc.public_subnet_ids
  eks_security_group_id      = module.vpc.eks_cluster_security_group_id
  eks_node_security_group_id = module.eks.node_security_group_id
  db_name                    = var.db_name
  db_username                = var.db_username
  db_instance_class          = var.db_instance_class
  db_allocated_storage       = var.db_allocated_storage
  multi_az                   = var.multi_az
  backup_retention_period    = var.backup_retention_period
}

module "secrets" {
  source = "../../modules/secrets"

  project_name         = var.project_name
  environment          = var.environment
  openai_api_key       = var.openai_api_key
  create_openai_secret = var.create_openai_secret
  tags                 = local.common_tags
}

module "dns_ingress" {
  count = var.enable_dns_ingress ? 1 : 0

  source = "../../modules/dns-ingress"

  environment            = var.environment
  root_domain_name       = var.root_domain_name
  app_subdomain          = var.app_subdomain
  additional_subdomains  = [var.argocd_subdomain, var.grafana_subdomain, var.prometheus_subdomain]
  aws_region             = var.aws_region
  cluster_name           = module.eks.cluster_name
  cluster_endpoint       = module.eks.cluster_endpoint
  cluster_ca_certificate = module.eks.cluster_certificate_authority_data
  tags                   = local.common_tags
}

module "addons" {
  source = "../../modules/addons"

  cluster_name                          = module.eks.cluster_name
  aws_region                            = var.aws_region
  vpc_id                                = module.vpc.vpc_id
  environment                           = var.environment
  application_namespace                 = local.name_prefix
  oidc_provider_arn                     = module.eks.oidc_provider_arn
  oidc_provider_url                     = module.eks.oidc_provider_url
  secrets_manager_secret_arns           = [module.rds.db_secret_arn]
  external_secrets_role_arn             = module.eks.external_secrets_role_arn
  aws_load_balancer_controller_role_arn = module.eks.lb_controller_role_arn
  grafana_service_type                  = var.grafana_service_type
  enable_platform_ingress               = var.enable_dns_ingress
  root_domain_name                      = var.root_domain_name
  argocd_hostname                       = local.argocd_domain_name
  grafana_hostname                      = local.grafana_domain_name
  prometheus_hostname                   = local.prometheus_domain_name
  platform_certificate_arn              = try(module.dns_ingress[0].acm_certificate_arn, "")
  platform_alb_group_name               = "${local.name_prefix}-platform"
  platform_alb_name                     = "${local.name_prefix}-platform"
  argocd_repo_url                       = var.argocd_repo_url
  argocd_repo_username                  = var.argocd_repo_username
  argocd_repo_token                     = var.argocd_repo_token
  tags                                  = local.common_tags

  depends_on = [
    module.eks,
    module.rds
  ]
}