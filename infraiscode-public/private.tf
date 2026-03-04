resource "tls_private_key" "wordpress_ssh" {
  algorithm = "RSA"
  rsa_bits  = 2048
}
resource "aws_key_pair" "ssh_key" {
  key_name   = "wordpress-ssh-key"
  public_key = tls_private_key.wordpress_ssh.public_key_openssh
}
resource "local_file" "ssh_private_key" {
  content  = tls_private_key.wordpress_ssh.private_key_pem
  filename = "./id_rsa_wordpress.pem"
}