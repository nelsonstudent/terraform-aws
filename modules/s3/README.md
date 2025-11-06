# Módulo Terraform - AWS S3

Este módulo cria e gerencia buckets S3 na AWS com configuração completa de versionamento, lifecycle, replicação e segurança.

## Recursos Criados

- ✅ Bucket S3 com configuração completa
- ✅ Versionamento
- ✅ Criptografia server-side (SSE)
- ✅ Public Access Block
- ✅ Lifecycle Rules
- ✅ Logging de acesso (opcional)
- ✅ CORS Configuration (opcional)
- ✅ Static Website Hosting (opcional)
- ✅ Replicação cross-region (opcional)
- ✅ Object Lock (opcional)
- ✅ Intelligent Tiering (opcional)
- ✅ Event Notifications (Lambda, SNS, SQS)

## Exemplos de Uso

### Exemplo 1: Bucket S3 Básico

```hcl
module "s3_basic" {
  source = "./modules/s3"

  bucket_name = "meu-bucket-unico-123"
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: Bucket com Versionamento e Criptografia

```hcl
module "s3_secure" {
  source = "./modules/s3"

  bucket_name = "meu-bucket-seguro-456"
  
  # Versionamento
  enable_versioning = true
  
  # Criptografia com KMS
  encryption_algorithm = "aws:kms"
  kms_master_key_id    = aws_kms_key.s3.arn
  bucket_key_enabled   = true
  
  # Bloquear acesso público
  block_public_access = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 3: Bucket com Lifecycle Rules

```hcl
module "s3_lifecycle" {
  source = "./modules/s3"

  bucket_name       = "meu-bucket-lifecycle-789"
  enable_versioning = true
  
  # Lifecycle Rules
  lifecycle_rules = [
    {
      id     = "archive-old-objects"
      status = "Enabled"
      prefix = "logs/"
      
      transitions = [
        {
          days          = 30
          storage_class = "STANDARD_IA"
        },
        {
          days          = 90
          storage_class = "GLACIER"
        },
        {
          days          = 180
          storage_class = "DEEP_ARCHIVE"
        }
      ]
      
      expiration_days = 365
    },
    {
      id     = "delete-temp-files"
      status = "Enabled"
      prefix = "temp/"
      
      expiration_days = 7
    },
    {
      id     = "cleanup-old-versions"
      status = "Enabled"
      
      noncurrent_version_expiration_days = 30
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 4: Bucket para Static Website

```hcl
module "s3_website" {
  source = "./modules/s3"

  bucket_name = "meu-site-estatico-com"
  
  # Website Hosting
  enable_website         = true
  website_index_document = "index.html"
  website_error_document = "error.html"
  
  # CORS para website
  cors_rules = [
    {
      allowed_methods = ["GET", "HEAD"]
      allowed_origins = ["https://meusite.com"]
      allowed_headers = ["*"]
      max_age_seconds = 3000
    }
  ]
  
  # Permitir acesso público para website
  block_public_access = false
  
  # Policy para permitir leitura pública
  bucket_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource  = "arn:aws:s3:::meu-site-estatico-com/*"
      }
    ]
  })
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 5: Bucket com Logging

```hcl
# Bucket para logs
module "s3_logs" {
  source = "./modules/s3"

  bucket_name         = "meus-logs-s3-bucket"
  block_public_access = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}

# Bucket principal com logging
module "s3_with_logging" {
  source = "./modules/s3"

  bucket_name = "meu-bucket-principal"
  
  # Logging
  enable_logging        = true
  logging_target_bucket = module.s3_logs.bucket_name
  logging_target_prefix = "access-logs/"
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 6: Bucket com Replicação Cross-Region

```hcl
# Bucket de origem
module "s3_source" {
  source = "./modules/s3"

  bucket_name       = "meu-bucket-origem"
  enable_versioning = true
  
  # Replicação
  enable_replication   = true
  replication_role_arn = aws_iam_role.replication.arn
  
  replication_rules = [
    {
      id                 = "replicate-all"
      status             = "Enabled"
      destination_bucket = "arn:aws:s3:::meu-bucket-destino"
      storage_class      = "STANDARD_IA"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}

# Bucket de destino (em outra região)
module "s3_destination" {
  source = "./modules/s3"
  
  providers = {
    aws = aws.us-west-2
  }

  bucket_
