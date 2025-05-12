
resource "aws_internet_gateway" "igw_publica" {
  vpc_id = aws_vpc.srewordpressturbinado_publica.id

  tags = {
    Name = "IGW_publica"
  }
}


resource "aws_egress_only_internet_gateway" "wordpressturbinado" {
  vpc_id = aws_vpc.srewordpressturbinado_publica.id

  tags = {
    Name = "egress-wordpressturbinado"
  }
}

resource "aws_route_table" "default_publica_route_table" {
  vpc_id = aws_vpc.srewordpressturbinado_publica.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_publica.id
  }

  route {
    ipv6_cidr_block        = "::/0"
    egress_only_gateway_id = aws_egress_only_internet_gateway.wordpressturbinado.id
  }

  tags = {
    Name = "redewordpressturbinado-route"
  }
}


