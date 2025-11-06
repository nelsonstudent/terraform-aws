# ===============================
# Arquivo principal do Terraform
# ===============================

terraform {
  required_version = ">= 1.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    }
  }
}

# ==========================================
# VPC Module
# ==========================================
module "vpc" {
  source = "./modules/vpc"

  vpc_cidr             = var.vpc_cidr
  public_subnet_cidrs  = var.vpc.public_subnet_cidrs
  private_subnet_cidrs = var.vpc.private_subnet_cidrs
  availability_zones   = var.vpc.availability_zones
  project_name         = var.vpc.project_name
  environment          = var.vpc.environment
}

# ==========================================
# IAM Module
# ==========================================
module "iam" {
  source = "./modules/iam"

  project_name = var.project_name
  environment  = var.environment
}

# ==========================================
# EC2 Module
# ==========================================
module "ec2" {
  source = "./modules/ec2"

  instance_type          = var.ec2_instance_type
  ami_id                 = var.ec2_ami_id
  subnet_id              = module.vpc.public_subnet_ids[0]
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  iam_instance_profile   = module.iam.ec2_instance_profile_name
  key_name               = var.ec2_key_name
  project_name           = var.project_name
  environment            = var.environment

  depends_on = [module.vpc, module.iam]
}

# ==========================================
# Lambda Module
# ==========================================
module "lambda" {
  source = "./modules/lambda"

  function_name      = var.lambda_function_name
  runtime            = var.lambda_runtime
  handler            = var.lambda_handler
  lambda_role_arn    = module.iam.lambda_role_arn
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.default_security_group_id]
  source_code_path   = var.lambda_source_code_path
  environment_vars   = var.lambda_environment_vars
  project_name       = var.project_name
  environment        = var.environment

  depends_on = [module.vpc, module.iam]
}

# ==========================================
# S3 Module
# ==========================================
module "s3" {
  source = "./modules/s3"

  bucket_name         = var.s3_bucket_name
  enable_versioning   = var.s3_enable_versioning
  enable_encryption   = var.s3_enable_encryption
  block_public_access = var.s3_block_public_access
  project_name        = var.project_name
  environment         = var.environment
}

# ==========================================
# EBS Module
# ==========================================
module "ebs" {
  source = "./modules/ebs"

  availability_zone = var.availability_zones[0]
  size              = var.ebs_volume_size
  volume_type       = var.ebs_volume_type
  iops              = var.ebs_iops
  encrypted         = var.ebs_encrypted
  project_name      = var.project_name
  environment       = var.environment
}

# ==========================================
# RDS Module
# ==========================================
module "rds" {
  source = "./modules/rds"

  allocated_storage      = var.rds_allocated_storage
  engine                 = var.rds_engine
  engine_version         = var.rds_engine_version
  instance_class         = var.rds_instance_class
  db_name                = var.rds_db_name
  username               = var.rds_username
  password               = var.rds_password
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [module.vpc.default_security_group_id]
  multi_az               = var.rds_multi_az
  backup_retention_period = var.rds_backup_retention_period
  skip_final_snapshot    = var.rds_skip_final_snapshot
  project_name           = var.project_name
  environment            = var.environment

  depends_on = [module.vpc]
}

# ==========================================
# DynamoDB Module
# ==========================================
module "dynamodb" {
  source = "./modules/dynamodb"

  table_name     = var.dynamodb_table_name
  hash_key       = var.dynamodb_hash_key
  range_key      = var.dynamodb_range_key
  billing_mode   = var.dynamodb_billing_mode
  read_capacity  = var.dynamodb_read_capacity
  write_capacity = var.dynamodb_write_capacity
  attributes     = var.dynamodb_attributes
  project_name   = var.project_name
  environment    = var.environment
}
