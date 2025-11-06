# ==========================================
# Global Variables
# ==========================================
variable "aws_region" {
  description = "AWS region onde os recursos serão criados"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Nome do projeto (usado para tags e nomenclatura)"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

# ==========================================
# VPC Variables
# ==========================================
variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDR blocks para subnets públicas"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDR blocks para subnets privadas"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
}

variable "availability_zones" {
  description = "Lista de availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# ==========================================
# EC2 Variables
# ==========================================
variable "ec2_instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

variable "ec2_ami_id" {
  description = "AMI ID para a instância EC2 (ex: ami-0c55b159cbfafe1f0 para Amazon Linux 2)"
  type        = string
}

variable "ec2_key_name" {
  description = "Nome do key pair para acesso SSH à instância EC2"
  type        = string
  default     = null
}

# ==========================================
# Lambda Variables
# ==========================================
variable "lambda_function_name" {
  description = "Nome da função Lambda"
  type        = string
}

variable "lambda_runtime" {
  description = "Runtime da função Lambda"
  type        = string
  default     = "python3.11"
}

variable "lambda_handler" {
  description = "Handler da função Lambda"
  type        = string
  default     = "index.handler"
}

variable "lambda_source_code_path" {
  description = "Caminho para o código fonte da função Lambda (arquivo zip)"
  type        = string
  default     = "./lambda_function.zip"
}

variable "lambda_environment_vars" {
  description = "Variáveis de ambiente para a função Lambda"
  type        = map(string)
  default     = {}
}

# ==========================================
# S3 Variables
# ==========================================
variable "s3_bucket_name" {
  description = "Nome do bucket S3 (deve ser globalmente único)"
  type        = string
}

variable "s3_enable_versioning" {
  description = "Habilitar versionamento no bucket S3"
  type        = bool
  default     = true
}

variable "s3_enable_encryption" {
  description = "Habilitar criptografia no bucket S3"
  type        = bool
  default     = true
}

variable "s3_block_public_access" {
  description = "Bloquear acesso público ao bucket S3"
  type        = bool
  default     = true
}

# ==========================================
# EBS Variables
# ==========================================
variable "ebs_volume_size" {
  description = "Tamanho do volume EBS em GB"
  type        = number
  default     = 20
}

variable "ebs_volume_type" {
  description = "Tipo do volume EBS (gp2, gp3, io1, io2, st1, sc1)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.ebs_volume_type)
    error_message = "EBS volume type must be gp2, gp3, io1, io2, st1, or sc1."
  }
}

variable "ebs_iops" {
  description = "IOPS para volumes io1, io2 ou gp3"
  type        = number
  default     = null
}

variable "ebs_encrypted" {
  description = "Habilitar criptografia no volume EBS"
  type        = bool
  default     = true
}

# ==========================================
# RDS Variables
# ==========================================
variable "rds_allocated_storage" {
  description = "Tamanho do storage alocado para RDS em GB"
  type        = number
  default     = 20
}

variable "rds_engine" {
  description = "Engine do RDS (mysql, postgres, mariadb, etc)"
  type        = string
  default     = "mysql"
}

variable "rds_engine_version" {
  description = "Versão da engine do RDS"
  type        = string
  default     = "8.0"
}

variable "rds_instance_class" {
  description = "Classe da instância RDS"
  type        = string
  default     = "db.t3.micro"
}

variable "rds_db_name" {
  description = "Nome do database inicial"
  type        = string
}

variable "rds_username" {
  description = "Username master do RDS"
  type        = string
}

variable "rds_password" {
  description = "Password master do RDS"
  type        = string
  sensitive   = true
}

variable "rds_multi_az" {
  description = "Habilitar Multi-AZ para alta disponibilidade"
  type        = bool
  default     = false
}

variable "rds_backup_retention_period" {
  description = "Período de retenção de backup em dias"
  type        = number
  default     = 7
}

variable "rds_skip_final_snapshot" {
  description = "Pular snapshot final ao deletar o RDS"
  type        = bool
  default     = true
}

# ==========================================
# DynamoDB Variables
# ==========================================
variable "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  type        = string
}

variable "dynamodb_hash_key" {
  description = "Chave hash (partition key) da tabela"
  type        = string
  default     = "id"
}

variable "dynamodb_range_key" {
  description = "Chave range (sort key) da tabela"
  type        = string
  default     = null
}

variable "dynamodb_billing_mode" {
  description = "Modo de billing (PROVISIONED ou PAY_PER_REQUEST)"
  type        = string
  default     = "PAY_PER_REQUEST"

  validation {
    condition     = contains(["PROVISIONED", "PAY_PER_REQUEST"], var.dynamodb_billing_mode)
    error_message = "Billing mode must be PROVISIONED or PAY_PER_REQUEST."
  }
}

variable "dynamodb_read_capacity" {
  description = "Read capacity units (usado apenas se billing_mode = PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_write_capacity" {
  description = "Write capacity units (usado apenas se billing_mode = PROVISIONED)"
  type        = number
  default     = 5
}

variable "dynamodb_attributes" {
  description = "Lista de atributos da tabela"
  type = list(object({
    name = string
    type = string
  }))
  default = [
    {
      name = "id"
      type = "S"
    }
  ]
}
