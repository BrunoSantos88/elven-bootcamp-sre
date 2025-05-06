# VPC
resource "aws_vpc" "srewordpressturbinado" {
  cidr_block                       = "172.16.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "wordpressrede"
  }
}

# Subnets
resource "aws_subnet" "wordpressrede_a" {
  vpc_id            = aws_vpc.srewordpressturbinado.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-a-wordpressrede"
  }
}

resource "aws_subnet" "wordpressrede_b" {
  vpc_id            = aws_vpc.srewordpressturbinado.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-b-wordpressrede"
  }
}

resource "aws_subnet" "wordpressrede_c" {
  vpc_id            = aws_vpc.srewordpressturbinado.id
  cidr_block        = "172.16.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "subnet-c-wordpressrede"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.srewordpressturbinado.id

  tags = {
    Name = "main"
  }
}

# Egress-Only Internet Gateway (para IPv6)
resource "aws_egress_only_internet_gateway" "wordpressturbinadole" {
  vpc_id = aws_vpc.srewordpressturbinado.id

  tags = {
    Name = "main"
  }
}

# Route Table (Default)
resource "aws_default_route_table" "wordpressturbinado" {
  default_route_table_id = aws_vpc.srewordpressturbinado.default_route_table_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.wordpressturbinadole.id
  }

  tags = {
    Name = "redewordpressturbinado"
  }
}

# Route Table Association (apenas para uma das subnets; você pode adicionar mais se quiser)
resource "aws_route_table_association" "a" {
  subnet_id      = aws_subnet.wordpressrede_a.id
  route_table_id = aws_default_route_table.wordpressturbinado.id
}
