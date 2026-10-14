# 1. Security Group Capa 1: Application Load Balancer (ALB)
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-sg-alb"
  description = "Capa 1 Publica: Permite HTTP (80) y HTTPS (443) desde Internet"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP desde cualquier origen"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS desde cualquier origen"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-alb"
  }
}

# 2. Security Group Capa 2: EKS Aplicacion
resource "aws_security_group" "eks" {
  name        = "${var.project_name}-sg-eks"
  description = "Capa 2 Privada App: Permite trafico desde SG del ALB y comunicacion interna EKS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "HTTP desde SG del ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "HTTPS desde SG del ALB"
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description     = "NodePort de Kubernetes desde SG del ALB"
    from_port       = 30080
    to_port         = 30080
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }

  ingress {
    description = "Comunicacion interna entre nodos y pods del cluster EKS"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-eks"
  }
}

# 3. Security Group Capa 3: RDS Base de Datos MySQL
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-sg-rds"
  description = "Capa 3 Privada Datos: Permite 3306 (MySQL) exclusivamente desde SG de EKS"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL desde SG de EKS Aplicacion"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.eks.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-sg-rds"
  }
}