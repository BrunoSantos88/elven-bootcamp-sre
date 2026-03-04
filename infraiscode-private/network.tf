# Internet Gateway (necessário para o NAT Gateway ter saída)
resource "aws_internet_gateway" "igw_private" {
  vpc_id = aws_vpc.private.id

  tags = {
    Name = "igw-vpc-privada"
  }
}

# Elastic IP para o NAT Gateway
resource "aws_eip" "nat_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.igw_private]

  tags = {
    Name = "nat-eip-privada"
  }
}

# NAT Gateway na subnet pública da VPC privada
resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.nat_subnet.id
  depends_on    = [aws_internet_gateway.igw_private]

  tags = {
    Name = "nat-gw-privada"
  }
}

# Route table pública (para o NAT Gateway ter saída via IGW)
resource "aws_route_table" "rt_nat" {
  vpc_id = aws_vpc.private.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_private.id
  }

  tags = {
    Name = "rt-nat-subnet"
  }
}

resource "aws_route_table_association" "nat_subnet" {
  subnet_id      = aws_subnet.nat_subnet.id
  route_table_id = aws_route_table.rt_nat.id
}

# Route table privada — saída pelo NAT + rota para VPC pública via Peering
resource "aws_route_table" "rt_privada" {
  vpc_id = aws_vpc.private.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gw.id
  }

  route {
    cidr_block                = "172.16.0.0/16"
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

  tags = {
    Name = "rt-privada"
  }
}

resource "aws_route_table_association" "privada_1" {
  subnet_id      = aws_subnet.privada_1.id
  route_table_id = aws_route_table.rt_privada.id
}

resource "aws_route_table_association" "privada_2" {
  subnet_id      = aws_subnet.privada_2.id
  route_table_id = aws_route_table.rt_privada.id
}

resource "aws_route_table_association" "privada_3" {
  subnet_id      = aws_subnet.privada_3.id
  route_table_id = aws_route_table.rt_privada.id
}
