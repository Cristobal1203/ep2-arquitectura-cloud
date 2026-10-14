# 1. VPC Principal (/22)
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# 2. Internet Gateway para la Capa 1 Publica
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# 3. CAPA 1: 2 Subredes Publicas (AZ 1a y AZ 1b)
resource "aws_subnet" "public_1a" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.0/25"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project_name}-public-subnet-1a"
    "kubernetes.io/role/elb" = "1"
  }
}

resource "aws_subnet" "public_1b" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = "10.0.0.128/25"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name                     = "${var.project_name}-public-subnet-1b"
    "kubernetes.io/role/elb" = "1"
  }
}

# 4. CAPA 2: 2 Subredes Privadas de Aplicacion para EKS (AZ 1a y AZ 1b)
resource "aws_subnet" "private_app_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name                              = "${var.project_name}-private-app-1a"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

resource "aws_subnet" "private_app_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name                              = "${var.project_name}-private-app-1b"
    "kubernetes.io/role/internal-elb" = "1"
  }
}

# 5. CAPA 3: 2 Subredes Privadas de Datos para RDS Multi-AZ (AZ 1a y AZ 1b)
resource "aws_subnet" "private_data_1a" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.0/25"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project_name}-private-data-1a"
  }
}

resource "aws_subnet" "private_data_1b" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.3.128/25"
  availability_zone = "us-east-1b"

  tags = {
    Name = "${var.project_name}-private-data-1b"
  }
}

# 6. Elastic IP y NAT Gateway para salida controlada a Internet
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_1a.id

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.igw]
}

# 7. Tabla de Enrutamiento Publica (hacia IGW)
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

resource "aws_route_table_association" "public_1a" {
  subnet_id      = aws_subnet.public_1a.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_1b" {
  subnet_id      = aws_subnet.public_1b.id
  route_table_id = aws_route_table.public.id
}

# 8. Tabla de Enrutamiento Privada (hacia NAT Gateway)
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

resource "aws_route_table_association" "private_app_1a" {
  subnet_id      = aws_subnet.private_app_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_app_1b" {
  subnet_id      = aws_subnet.private_app_1b.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_data_1a" {
  subnet_id      = aws_subnet.private_data_1a.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_data_1b" {
  subnet_id      = aws_subnet.private_data_1b.id
  route_table_id = aws_route_table.private.id
}