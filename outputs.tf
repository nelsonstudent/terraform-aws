# ==========================================
# VPC Outputs
# ==========================================
output "vpc_id" {
  description = "ID da VPC criada"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "CIDR block da VPC"
  value       = module.vpc.vpc_cidr
}

output "public_subnet_ids" {
  description = "IDs das subnets públicas"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "IDs das subnets privadas"
  value       = module.vpc.private_subnet_ids
}

output "internet_gateway_id" {
  description = "ID do Internet Gateway"
  value       = module.vpc.internet_gateway_id
}

output "nat_gateway_ids" {
  description = "IDs dos NAT Gateways"
  value       = module.vpc.nat_gateway_ids
}

# ==========================================
# IAM Outputs
# ==========================================
output "ec2_instance_profile_name" {
  description = "Nome do IAM instance profile para EC2"
  value       = module.iam.ec2_instance_profile_name
}

output "ec2_role_arn" {
  description = "ARN da IAM role para EC2"
  value       = module.iam.ec2_role_arn
}

output "lambda_role_arn" {
  description = "ARN da IAM role para Lambda"
  value       = module.iam.lambda_role_arn
}

# ==========================================
# EC2 Outputs
# ==========================================
output "ec2_instance_id" {
  description = "ID da instância EC2"
  value       = module.ec2.instance_id
}

output "ec2_instance_state" {
  description = "Estado da instância EC2"
  value       = module.ec2.instance_state
}

output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = module.ec2.public_ip
}

output "ec2_private_ip" {
  description = "IP privado da instância EC2"
  value       = module.ec2.private_ip
}

output "ec2_public_dns" {
  description = "DNS público da instância EC2"
  value       = module.ec2.public_dns
}

# ==========================================
# Lambda Outputs
# ==========================================
output "lambda_function_name" {
  description = "Nome da função Lambda"
  value       = module.lambda.function_name
}

output "lambda_function_arn" {
  description = "ARN da função Lambda"
  value       = module.lambda.function_arn
}

output "lambda_invoke_arn" {
  description = "ARN de invocação da função Lambda"
  value       = module.lambda.invoke_arn
}

output "lambda_version" {
  description = "Versão da função Lambda"
  value       = module.lambda.version
}

# ==========================================
# S3 Outputs
# ==========================================
output "s3_bucket_id" {
  description = "ID do bucket S3"
  value       = module.s3.bucket_id
}

output "s3_bucket_name" {
  description = "Nome do bucket S3"
  value       = module.s3.bucket_name
}

output "s3_bucket_arn" {
  description = "ARN do bucket S3"
  value       = module.s3.bucket_arn
}

output "s3_bucket_domain_name" {
  description = "Domain name do bucket S3"
  value       = module.s3.bucket_domain_name
}

output "s3_bucket_regional_domain_name" {
  description = "Regional domain name do bucket S3"
  value       = module.s3.bucket_regional_domain_name
}

# ==========================================
# EBS Outputs
# ==========================================
output "ebs_volume_id" {
  description = "ID do volume EBS"
  value       = module.ebs.volume_id
}

output "ebs_volume_arn" {
  description = "ARN do volume EBS"
  value       = module.ebs.volume_arn
}

output "ebs_volume_size" {
  description = "Tamanho do volume EBS em GB"
  value       = module.ebs.volume_size
}

output "ebs_volume_type" {
  description = "Tipo do volume EBS"
  value       = module.ebs.volume_type
}

# ==========================================
# RDS Outputs
# ==========================================
output "rds_instance_id" {
  description = "ID da instância RDS"
  value       = module.rds.instance_id
}

output "rds_instance_arn" {
  description = "ARN da instância RDS"
  value       = module.rds.instance_arn
}

output "rds_endpoint" {
  description = "Endpoint de conexão do RDS"
  value       = module.rds.endpoint
}

output "rds_address" {
  description = "Endereço do RDS (hostname)"
  value       = module.rds.address
}

output "rds_port" {
  description = "Porta do RDS"
  value       = module.rds.port
}

output "rds_database_name" {
  description = "Nome do database"
  value       = module.rds.database_name
}

# ==========================================
# DynamoDB Outputs
# ==========================================
output "dynamodb_table_id" {
  description = "ID da tabela DynamoDB"
  value       = module.dynamodb.table_id
}

output "dynamodb_table_name" {
  description = "Nome da tabela DynamoDB"
  value       = module.dynamodb.table_name
}

output "dynamodb_table_arn" {
  description = "ARN da tabela DynamoDB"
  value       = module.dynamodb.table_arn
}

output "dynamodb_table_stream_arn" {
  description = "ARN do stream da tabela DynamoDB"
  value       = module.dynamodb.table_stream_arn
}

output "dynamodb_table_stream_label" {
  description = "Label do stream da tabela DynamoDB"
  value       = module.dynamodb.table_stream_label
}

# ==========================================
# Summary Output
# ==========================================
output "infrastructure_summary" {
  description = "Resumo da infraestrutura criada"
  value = {
    region      = var.aws_region
    project     = var.project_name
    environment = var.environment
    vpc_id      = module.vpc.vpc_id
    resources = {
      ec2      = module.ec2.instance_id
      lambda   = module.lambda.function_name
      s3       = module.s3.bucket_name
      ebs      = module.ebs.volume_id
      rds      = module.rds.instance_id
      dynamodb = module.dynamodb.table_name
    }
  }
}
