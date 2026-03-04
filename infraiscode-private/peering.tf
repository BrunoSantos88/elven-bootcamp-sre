# VPC pública gerenciada pelo infraiscode-public
data "aws_vpc" "publica" {
  id = var.vpc_publica_id
}

# Busca a route table pública para adicionar rota de retorno
data "aws_route_table" "publica" {
  vpc_id = data.aws_vpc.publica.id

  filter {
    name   = "tag:Name"
    values = ["redewordpressturbinado-route"]
  }
}

# VPC Peering: VPC pública <-> VPC privada
resource "aws_vpc_peering_connection" "peer" {
  vpc_id      = data.aws_vpc.publica.id
  peer_vpc_id = aws_vpc.private.id
  auto_accept = true

  tags = {
    Name = "peering-publica-privada"
  }
}

# Rota na VPC pública apontando para a VPC privada via Peering
resource "aws_route" "publica_to_privada" {
  route_table_id            = data.aws_route_table.publica.id
  destination_cidr_block    = "10.0.0.0/16"
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}
