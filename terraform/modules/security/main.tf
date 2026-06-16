resource "aws_security_group" "alb" {
  name        = "${var.name_prefix}-alb-sg"
  description = "Security group for the public ALB"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-alb-sg"
  })
}

resource "aws_security_group_rule" "alb_http_in" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  description       = "HTTP from Internet"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_argocd_in" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  description       = "ArgoCD UI from Internet"
  from_port         = var.argocd_alb_port
  to_port           = var.argocd_alb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_grafana_in" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  description       = "Grafana UI from Internet"
  from_port         = var.grafana_alb_port
  to_port           = var.grafana_alb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_prometheus_in" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id
  description       = "Prometheus UI from Internet"
  from_port         = var.prometheus_alb_port
  to_port           = var.prometheus_alb_port
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_to_ec2" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  description              = "Forward traffic to EC2 application port"
  from_port                = var.node_port
  to_port                  = var.node_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "alb_to_ec2_argocd" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  description              = "Forward traffic to EC2 ArgoCD UI port"
  from_port                = var.argocd_host_port
  to_port                  = var.argocd_host_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "alb_to_ec2_grafana" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  description              = "Forward traffic to EC2 Grafana port"
  from_port                = var.grafana_host_port
  to_port                  = var.grafana_host_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group_rule" "alb_to_ec2_prometheus" {
  type                     = "egress"
  security_group_id        = aws_security_group.alb.id
  description              = "Forward traffic to EC2 Prometheus port"
  from_port                = var.prometheus_host_port
  to_port                  = var.prometheus_host_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.ec2.id
}

resource "aws_security_group" "ec2" {
  name        = "${var.name_prefix}-ec2-sg"
  description = "Security group for the private EC2 minikube host"
  vpc_id      = var.vpc_id

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ec2-sg"
  })
}

resource "aws_security_group_rule" "ec2_from_alb" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2.id
  description              = "Application port from ALB"
  from_port                = var.node_port
  to_port                  = var.node_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_from_alb_argocd" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2.id
  description              = "ArgoCD UI port from ALB"
  from_port                = var.argocd_host_port
  to_port                  = var.argocd_host_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_from_alb_grafana" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2.id
  description              = "Grafana port from ALB"
  from_port                = var.grafana_host_port
  to_port                  = var.grafana_host_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_from_alb_prometheus" {
  type                     = "ingress"
  security_group_id        = aws_security_group.ec2.id
  description              = "Prometheus port from ALB"
  from_port                = var.prometheus_host_port
  to_port                  = var.prometheus_host_port
  protocol                 = "tcp"
  source_security_group_id = aws_security_group.alb.id
}

resource "aws_security_group_rule" "ec2_egress" {
  type              = "egress"
  security_group_id = aws_security_group.ec2.id
  description       = "Outbound Internet through NAT Gateway"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
}
