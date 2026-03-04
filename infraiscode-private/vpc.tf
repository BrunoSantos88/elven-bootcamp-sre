# VPC Privada
resource "aws_vpc" "private" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    Name = "vpc-privada-wordpress"
  }
}

# Subnet pública (apenas para o NAT Gateway)
resource "aws_subnet" "nat_subnet" {
  vpc_id            = aws_vpc.private.id
  cidr_block        = "10.0.0.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-nat-publica"
  }
}

# Subnets privadas para o RDS
resource "aws_subnet" "privada_1" {
  vpc_id            = aws_vpc.private.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-privada-1"
  }
}

resource "aws_subnet" "privada_2" {
  vpc_id            = aws_vpc.private.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-privada-2"
  }
}

resource "aws_subnet" "privada_3" {
  vpc_id            = aws_vpc.private.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "subnet-privada-3"
  }
}
