data "aws_ami" "ubuntu" {
  count       = var.ami_id == "" ? 1 : 0
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

module "network" {
  source = "./modules/network"

  name_prefix             = local.name_prefix
  vpc_cidr                = var.vpc_cidr
  public_subnet_cidrs     = var.public_subnet_cidrs
  private_subnet_cidr     = var.private_subnet_cidr
  rds_private_subnet_cidr = var.rds_private_subnet_cidr
  common_tags             = local.common_tags
}

module "security" {
  source = "./modules/security"

  name_prefix          = local.name_prefix
  vpc_id               = module.network.vpc_id
  node_port            = var.node_port
  argocd_alb_port      = var.argocd_alb_port
  argocd_host_port     = var.argocd_host_port
  grafana_alb_port     = var.grafana_alb_port
  grafana_host_port    = var.grafana_host_port
  prometheus_alb_port  = var.prometheus_alb_port
  prometheus_host_port = var.prometheus_host_port
  common_tags          = local.common_tags
}

resource "aws_vpc_endpoint" "secretsmanager" {
  vpc_id              = module.network.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.secretsmanager"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = [module.network.private_subnet_id]
  private_dns_enabled = true
  security_group_ids  = [module.security.secretsmanager_endpoint_security_group_id]

  tags = merge(local.common_tags, {
    Name = "${local.name_prefix}-secretsmanager-endpoint"
  })
}

module "rds" {
  source = "./modules/rds"

  name_prefix       = local.name_prefix
  subnet_ids        = module.network.private_subnet_ids
  security_group_id = module.security.rds_security_group_id
  instance_class    = var.rds_instance_class
  engine_version    = var.rds_engine_version
  database_name     = var.rds_database_name
  username          = var.rds_username
  common_tags       = local.common_tags
}

module "ec2" {
  source = "./modules/ec2"

  name_prefix               = local.name_prefix
  instance_name             = "${local.name_prefix}-minikube"
  private_subnet_id         = module.network.private_subnet_id
  ec2_security_group_id     = module.security.ec2_security_group_id
  instance_type             = var.instance_type
  ami_id                    = var.ami_id != "" ? var.ami_id : data.aws_ami.ubuntu[0].id
  root_volume_size          = var.root_volume_size
  node_port                 = var.node_port
  argocd_host_port          = var.argocd_host_port
  grafana_host_port         = var.grafana_host_port
  prometheus_host_port      = var.prometheus_host_port
  kubectl_version           = var.kubectl_version
  minikube_version          = var.minikube_version
  gitops_repo_url           = var.gitops_repo_url
  secretsmanager_secret_arn = module.rds.master_secret_arn
  private_key_path          = local.private_key_path
  common_tags               = local.common_tags

  # Chờ toàn bộ network module hoàn tất, đặc biệt là NAT Gateway và private route,
  # trước khi EC2 boot user-data cần outbound Internet để cài package.
  depends_on = [module.network]
}

module "alb" {
  source = "./modules/alb"

  name_prefix            = local.name_prefix
  vpc_id                 = module.network.vpc_id
  public_subnet_ids      = module.network.public_subnet_ids
  alb_security_group_id  = module.security.alb_security_group_id
  target_instance_id     = module.ec2.instance_id
  target_port            = var.node_port
  argocd_alb_port        = var.argocd_alb_port
  argocd_target_port     = var.argocd_host_port
  grafana_alb_port       = var.grafana_alb_port
  grafana_target_port    = var.grafana_host_port
  prometheus_alb_port    = var.prometheus_alb_port
  prometheus_target_port = var.prometheus_host_port
  common_tags            = local.common_tags
}
