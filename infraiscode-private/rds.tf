# Busca security group das EC2 para liberar acesso ao RDS
data "aws_security_group" "ec2_wordpress" {
  vpc_id = data.aws_vpc.publica.id

  filter {
    name   = "tag:Name"
    values = ["allow_ssh_http_node"]
  }
}

# Security group do RDS — aceita MySQL apenas das EC2 via Peering
resource "aws_security_group" "rds" {
  name        = "allow_rds_from_ec2"
  description = "Allow MySQL from EC2 instances via VPC Peering"
  vpc_id      = aws_vpc.private.id

  ingress {
    description = "MySQL from EC2 VPC"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["172.16.0.0/16"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow_rds"
  }
}

# Subnet group com as 3 subnets privadas
resource "aws_db_subnet_group" "rds" {
  name = "rds-private-subnet-group"

  subnet_ids = [
    aws_subnet.privada_1.id,
    aws_subnet.privada_2.id,
    aws_subnet.privada_3.id,
  ]

  tags = {
    Name = "rds-private-subnet-group"
  }
}

# Senha via SSM Parameter Store
data "aws_ssm_parameter" "db_password" {
  name            = "/wordpress/db_password"
  with_decryption = true
}

# RDS MySQL na rede privada
resource "aws_db_instance" "wordpress_rds" {
  identifier        = "wordpress-rds"
  engine            = "mysql"
  engine_version    = "8.0"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_type      = "gp2"

  db_name  = "wordpress"
  username = var.db_username
  password = data.aws_ssm_parameter.db_password.value

  db_subnet_group_name   = aws_db_subnet_group.rds.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  multi_az            = false
  skip_final_snapshot = true
  publicly_accessible = false

  tags = {
    Name = "wordpress-rds"
  }
}

output "rds_endpoint" {
  description = "Endpoint do RDS — use como db_host no Ansible"
  value       = aws_db_instance.wordpress_rds.address
}
