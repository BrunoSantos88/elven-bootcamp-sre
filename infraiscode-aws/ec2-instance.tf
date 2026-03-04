data "aws_ami" "amzn-linux-2023-ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

# Instância WordPress A
resource "aws_instance" "wordpress_b" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.wordpressrede_b.id
  key_name                    = "my-ed25519-key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sc-ec2-wordpress.id]

  tags = {
    Name = "wordpress_b"
  }
}

resource "aws_instance" "wordpress_a" {
  ami                         = data.aws_ami.amzn-linux-2023-ami.id
  instance_type               = "t3.large"
  subnet_id                   = aws_subnet.wordpressrede_a.id
  key_name                    = "my-ed25519-key"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sc-ec2-wordpress.id]

  tags = {
    Name = "wordpress_a"
  }
}