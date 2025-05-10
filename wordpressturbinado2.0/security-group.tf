resource "aws_security_group" "allow_tls" {
  name        = "Firewall-wordpressturbinado"
  description = "Allow TLS inbound traffic and all outbound traffic"
  vpc_id      = aws_vpc.srewordpressturbinado_publica.id

  tags = {
    Name = "secgroup-wordpressturbinado"
  }
}

resource "aws_vpc_security_group_ingress_rule" "https" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.srewordpressturbinado_publica.cidr_block
  from_port         = 443
  ip_protocol       = "tcp"
  to_port           = 443
}



resource "aws_vpc_security_group_ingress_rule" "http" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.srewordpressturbinado_publica.cidr_block
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}



resource "aws_vpc_security_group_ingress_rule" "rds" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.srewordpressturbinado_publica.cidr_block
  from_port         = 3306
  ip_protocol       = "tcp"
  to_port           = 3306
}

resource "aws_vpc_security_group_ingress_rule" "ssh" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = aws_vpc.srewordpressturbinado_publica.cidr_block
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic_ipv4" {
  security_group_id = aws_security_group.allow_tls.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1" # semantically equivalent to all ports
}
