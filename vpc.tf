data "aws_availability_zones" "available" {
  state = "available"
}

# -------------------------
# VPC
# -------------------------

resource "aws_vpc" "eks_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "eks-vpc"

    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------
# Internet Gateway
# -------------------------

resource "aws_internet_gateway" "eks_igw" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-igw"
  }
}

# -------------------------
# Public Subnet A
# -------------------------

resource "aws_subnet" "public_a" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "eu-west-3a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-a"

    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------
# Public Subnet B
# -------------------------

resource "aws_subnet" "public_b" {
  vpc_id                  = aws_vpc.eks_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "eu-west-3b"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-b"

    "kubernetes.io/role/elb"                    = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------
# Private Subnet A
# -------------------------

resource "aws_subnet" "private_a" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.11.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "private-subnet-a"

    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------
# Private Subnet B
# -------------------------

resource "aws_subnet" "private_b" {
  vpc_id            = aws_vpc.eks_vpc.id
  cidr_block        = "10.0.12.0/24"
  availability_zone = "eu-west-3b"

  tags = {
    Name = "private-subnet-b"

    "kubernetes.io/role/internal-elb"           = "1"
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

# -------------------------
# Elastic IP for NAT
# -------------------------

resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }
}

# -------------------------
# NAT Gateway
# -------------------------

resource "aws_nat_gateway" "eks_nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_a.id

  depends_on = [
    aws_internet_gateway.eks_igw
  ]

  tags = {
    Name = "eks-nat-gateway"
  }
}

# -------------------------
# Public Route Table
# -------------------------

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-public-rt"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks_igw.id
}

# -------------------------
# Public Associations
# -------------------------

resource "aws_route_table_association" "public_a" {
  subnet_id      = aws_subnet.public_a.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_route_table_association" "public_b" {
  subnet_id      = aws_subnet.public_b.id
  route_table_id = aws_route_table.public_rt.id
}

# -------------------------
# Private Route Table
# -------------------------

resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.eks_vpc.id

  tags = {
    Name = "eks-private-rt"
  }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.eks_nat.id
}

# -------------------------
# Private Associations
# -------------------------

resource "aws_route_table_association" "private_a" {
  subnet_id      = aws_subnet.private_a.id
  route_table_id = aws_route_table.private_rt.id
}

resource "aws_route_table_association" "private_b" {
  subnet_id      = aws_subnet.private_b.id
  route_table_id = aws_route_table.private_rt.id
}