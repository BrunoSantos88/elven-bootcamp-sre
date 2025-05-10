# VPC Pública
resource "aws_vpc" "srewordpressturbinado_publica" {
  cidr_block                       = "172.16.0.0/16"
  assign_generated_ipv6_cidr_block = true

  tags = {
    Name = "wordpressrede-publica"
  }
}

# Subnets Públicas
resource "aws_subnet" "wordpressrede_a" {
  vpc_id            = aws_vpc.srewordpressturbinado_publica.id
  cidr_block        = "172.16.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "subnet-a-wordpressrede_publica"
  }
}

resource "aws_subnet" "wordpressrede_b" {
  vpc_id            = aws_vpc.srewordpressturbinado_publica.id
  cidr_block        = "172.16.2.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name = "subnet-b-wordpressrede_publica"
  }
}

resource "aws_subnet" "wordpressrede_c" {
  vpc_id            = aws_vpc.srewordpressturbinado_publica.id
  cidr_block        = "172.16.3.0/24"
  availability_zone = "us-east-1c"

  tags = {
    Name = "subnet-c-wordpressrede_publica"
  }
}

# Subnets Privadas
resource "aws_subnet" "wordpressrede_d" {
  vpc_id            = aws_vpc.srewordpressturbinado_publica.id
  cidr_block        = "172.16.4.0/24"
  availability_zone = "us-east-1d"

  tags = {
    Name = "subnet-d-wordpressrede_privada"
  }
}

resource "aws_subnet" "wordpressrede_e" {
  vpc_id            = aws_vpc.srewordpressturbinado_publica.id
  cidr_block        = "172.16.5.0/24"
  availability_zone = "us-east-1e"

  tags = {
    Name = "subnet-e-wordpressrede_privada"
  }
}

resource "aws_subnet" "wordpressrede_f" {
  vpc_id            = aws_vpc.srewordpressturbinado_publica.id
  cidr_block        = "172.16.6.0/24"
  availability_zone = "us-east-1f"

  tags = {
    Name = "subnet-f-wordpressrede_privada"
  }
}