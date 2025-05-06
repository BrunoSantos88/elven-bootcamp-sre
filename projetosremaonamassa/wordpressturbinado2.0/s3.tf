resource "aws_s3_bucket" "meu_bucket" {
  bucket = "meu-bucket-exemplo-123456" # deve ser único globalmente
  acl    = "private"

  tags = {
    Name        = "MeuBucket"
    Environment = "Dev"
  }
}