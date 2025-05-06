resource "aws_s3_bucket" "meu_bucket" {
  bucket = "dadosnos3wordpressturbinado2.0-06052025"
  acl    = "private"

  tags = {
    Name        = "MeuBucketSRE"
    Environment = "AutomationWordpress2.0"
  }
}