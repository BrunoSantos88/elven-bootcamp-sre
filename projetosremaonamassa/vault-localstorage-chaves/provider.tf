provider "vault" {
  address = var.vault_addr
  token   = var.vault_token
}

resource "vault_generic_secret" "aws_credentials" {
  path = "secret/aws/credentials"

  data_json = jsonencode({
    access_key = var.aws_access_key
    secret_key = var.aws_secret_key
  })
}

