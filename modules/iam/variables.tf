variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

# ==========================================
# EC2 Variables
# ==========================================
variable "ec2_custom_policy" {
  description = "Policy JSON customizada para EC2"
  type        = string
  default     = null
}

# ==========================================
# Lambda Variables
# ==========================================
variable "lambda_in_vpc" {
  description = "Se a função Lambda estará em VPC"
  type        = bool
  default     = true
}

variable "lambda_custom_policy" {
  description = "Policy JSON customizada para Lambda"
  type        = string
  default     = null
}

variable "lambda_enable_dynamodb_access" {
  description = "Habilitar acesso do Lambda ao DynamoDB"
  type        = bool
  default     = false
}

variable "lambda_dynamodb_table_arns" {
  description = "Lista de ARNs de tabelas DynamoDB para Lambda acessar"
  type        = list(string)
  default     = ["*"]
}

variable "lambda_enable_s3_access" {
  description = "Habilitar acesso do Lambda ao S3"
  type        = bool
  default     = false
}

variable "lambda_s3_bucket_arns" {
  description = "Lista de ARNs de buckets S3 para Lambda acessar"
  type        = list(string)
  default     = ["*"]
}

# ==========================================
# RDS Variables
# ==========================================
variable "enable_rds_monitoring_role" {
  description = "Criar role para RDS Enhanced Monitoring"
  type        = bool
  default     = false
}

# ==========================================
# Auto Scaling Variables
# ==========================================
variable "enable_autoscaling_role" {
  description = "Criar role para Application Auto Scaling"
  type        = bool
  default     = false
}
