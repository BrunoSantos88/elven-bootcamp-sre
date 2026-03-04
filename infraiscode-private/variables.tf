variable "vpc_publica_id" {
  description = "ID da VPC pública gerenciada pelo infraiscode-public"
  type        = string
  default     = "vpc-0fcfeefda10ee0977"
}

variable "db_username" {
  description = "Usuário master do RDS"
  type        = string
  default     = "wpuser"
}
