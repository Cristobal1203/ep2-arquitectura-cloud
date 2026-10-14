cat << 'EOF' > eks.tf
# 1. Clúster administrado Amazon EKS
resource "aws_eks_cluster" "main" {
  name     = "${var.project_name}-eks-cluster"
  role_arn = data.aws_iam_role.lab_role.arn
  version  = "1.29"

  vpc_config {
    subnet_ids              = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1b.id]
    security_group_ids      = [aws_security_group.eks.id]
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = {
    Name = "${var.project_name}-eks-cluster"
  }
}

# Permitimos que el Security Group nativo del clúster EKS acceda al puerto 3306 de RDS y reciba el 30080 del ALB
resource "aws_security_group_rule" "rds_allow_eks_cluster_sg" {
  type                     = "ingress"
  from_port                = 3306
  to_port                  = 3306
  protocol                 = "tcp"
  security_group_id        = aws_security_group.rds.id
  source_security_group_id = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

resource "aws_security_group_rule" "eks_cluster_sg_allow_alb" {
  type                     = "ingress"
  from_port                = 30080
  to_port                  = 30080
  protocol                 = "tcp"
  security_group_id        = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
  source_security_group_id = aws_security_group.alb.id
}

# 2. Launch Template para garantizar el Cifrado EBS (encrypted = true) en los nodos de EKS
resource "aws_launch_template" "eks_nodes" {
  name_prefix = "${var.project_name}-eks-node-lt-"

  block_device_mappings {
    device_name = "/dev/xvda"
    ebs {
      volume_size           = 30
      volume_type           = "gp3"
      encrypted             = true # Requisito EV2: Cifrado de volúmenes EBS de nodos EKS
      delete_on_termination = true
    }
  }

  vpc_security_group_ids = [aws_security_group.eks.id]

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "${var.project_name}-eks-node"
    }
  }
}

# 3. Node Group de EKS con Auto Scaling (Mínimo 2 / Máximo 4 nodos)
resource "aws_eks_node_group" "main" {
  cluster_name    = aws_eks_cluster.main.name
  node_group_name = "${var.project_name}-node-group"
  node_role_arn   = data.aws_iam_role.lab_role.arn
  subnet_ids      = [aws_subnet.private_app_1a.id, aws_subnet.private_app_1b.id]

  # Usamos t3.small (x86_64) para compatibilidad directa con imágenes Docker compiladas en PC x86.
  instance_types = ["t3.small"]
  ami_type       = "AL2_x86_64"

  launch_template {
    id      = aws_launch_template.eks_nodes.id
    version = aws_launch_template.eks_nodes.latest_version
  }

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 4
  }

  tags = {
    Name = "${var.project_name}-node-group"
  }
}
EOF