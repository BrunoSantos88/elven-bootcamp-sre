resource "aws_db_subnet_group" "dba_subnet_group" {
  name = "dba-subnet-group"

  subnet_ids = [
    aws_subnet.wordpressrede_d.id,
    aws_subnet.wordpressrede_e.id,
    aws_subnet.wordpressrede_f.id
  ]

  tags = {
    Name = "dba-subnet-group"
  }
}