# Associações de subnets públicas
resource "aws_route_table_association" "publica_a" {
  subnet_id      = aws_subnet.wordpressrede_a.id
  route_table_id = aws_route_table.default_publica_route_table.id
}

resource "aws_route_table_association" "publica_b" {
  subnet_id      = aws_subnet.wordpressrede_b.id
  route_table_id = aws_route_table.default_publica_route_table.id
}

resource "aws_route_table_association" "publica_c" {
  subnet_id      = aws_subnet.wordpressrede_c.id
  route_table_id = aws_route_table.default_publica_route_table.id
}


resource "aws_route_table_association" "publica_d" {
  subnet_id      = aws_subnet.wordpressrede_d.id
  route_table_id = aws_route_table.default_publica_route_table.id
}


resource "aws_route_table_association" "publica_e" {
  subnet_id      = aws_subnet.wordpressrede_e.id
  route_table_id = aws_route_table.default_publica_route_table.id
}


resource "aws_route_table_association" "publica_f" {
  subnet_id      = aws_subnet.wordpressrede_f.id
  route_table_id = aws_route_table.default_publica_route_table.id
}

