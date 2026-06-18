resource "aws_iam_role" "ssm" {
  name = "${var.name_prefix}-ssm-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-ssm-role"
  })
}

resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ssm.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy" "read_rds_secret" {
  name = "${var.name_prefix}-read-rds-secret"
  role = aws_iam_role.ssm.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:DescribeSecret",
          "secretsmanager:GetSecretValue"
        ]
        Resource = var.secretsmanager_secret_arn
      }
    ]
  })
}

resource "aws_iam_instance_profile" "ssm" {
  name = "${var.name_prefix}-ssm-profile"
  role = aws_iam_role.ssm.name
}

resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated" {
  key_name   = "${var.name_prefix}-generated"
  public_key = tls_private_key.ssh.public_key_openssh

  tags = merge(var.common_tags, {
    Name = "${var.name_prefix}-generated-key"
  })
}

resource "local_sensitive_file" "ssh_private_key" {
  filename        = var.private_key_path
  content         = tls_private_key.ssh.private_key_pem
  file_permission = "0600"
}

resource "aws_instance" "this" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.private_subnet_id
  associate_public_ip_address = false
  vpc_security_group_ids      = [var.ec2_security_group_id]
  iam_instance_profile        = aws_iam_instance_profile.ssm.name
  key_name                    = aws_key_pair.generated.key_name

  user_data_replace_on_change = true

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 3
  }

  user_data_base64 = base64gzip(templatefile("${path.root}/user_data.sh.tftpl", {
    gitops_repo_url      = var.gitops_repo_url
    kubectl_version      = var.kubectl_version
    minikube_version     = var.minikube_version
    node_port            = var.node_port
    argocd_host_port     = var.argocd_host_port
    grafana_host_port    = var.grafana_host_port
    prometheus_host_port = var.prometheus_host_port
    project_name         = var.name_prefix
  }))

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted   = true
  }

  tags = merge(var.common_tags, {
    Name = var.instance_name
    Role = "single-node-k8s"
  })

  depends_on = [
    aws_iam_role_policy_attachment.ssm_core,
    aws_iam_role_policy.read_rds_secret
  ]
}
