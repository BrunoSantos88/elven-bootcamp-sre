# roteamento rede privada

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.srewordpressturbinado-private.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.wordpressprivate.id
  }

  tags = {
    Name = "Private Route Table"
  }
}


resource "aws_nat_gateway" "wordpressprivate" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.wordpressrede_d.id
  tags = {
    Name = "gw NAT"
  }
}

# Internet Gateway
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.srewordpressturbinado-publica.id

  tags = {
    Name = "main"
  }
}


resource "aws_eip" "nat_eip" {
  vpc = true

  tags = {
    Name = "NAT EIP"
  }
}