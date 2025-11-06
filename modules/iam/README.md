# Módulo Terraform - AWS IAM

Este módulo cria roles e policies IAM para EC2, Lambda, RDS e outros serviços AWS com permissões adequadas.

## Recursos Criados

- ✅ IAM Role para EC2 com Instance Profile
- ✅ IAM Role para Lambda
- ✅ IAM Role para RDS Enhanced Monitoring (opcional)
- ✅ IAM Role para Application Auto Scaling (opcional)
- ✅ Policies gerenciadas (SSM, CloudWatch)
- ✅ Policies customizadas (opcional)
- ✅ Permissões para DynamoDB e S3 (Lambda)

## Exemplos de Uso

### Exemplo 1: Roles Básicas para EC2 e Lambda

```hcl
module "iam_basic" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: Lambda com Acesso ao DynamoDB

```hcl
module "iam_lambda_dynamodb" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  # Lambda em VPC
  lambda_in_vpc = true
  
  # Habilitar acesso ao DynamoDB
  lambda_enable_dynamodb_access = true
  lambda_dynamodb_table_arns = [
    "arn:aws:dynamodb:us-east-1:123456789012:table/usuarios",
    "arn:aws:dynamodb:us-east-1:123456789012:table/pedidos"
  ]
}
```

### Exemplo 3: Lambda com Acesso ao S3

```hcl
module "iam_lambda_s3" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  lambda_in_vpc = true
  
  # Habilitar acesso ao S3
  lambda_enable_s3_access = true
  lambda_s3_bucket_arns = [
    "arn:aws:s3:::meu-bucket-uploads",
    "arn:aws:s3:::meu-bucket-backups"
  ]
}
```

### Exemplo 4: EC2 com Policy Customizada

```hcl
module "iam_ec2_custom" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  # Policy customizada para EC2
  ec2_custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::meu-bucket/*"
      },
      {
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:PutItem"
        ]
        Resource = "arn:aws:dynamodb:*:*:table/minha-tabela"
      }
    ]
  })
}
```

### Exemplo 5: Lambda com Policy Customizada

```hcl
module "iam_lambda_custom" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  lambda_in_vpc = true
  
  # Policy customizada para Lambda
  lambda_custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ses:SendEmail",
          "ses:SendRawEmail"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "sns:Publish"
        ]
        Resource = "arn:aws:sns:us-east-1:123456789012:notificacoes"
      }
    ]
  })
}
```

### Exemplo 6: Com RDS Enhanced Monitoring

```hcl
module "iam_with_rds" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  # Criar role para RDS Enhanced Monitoring
  enable_rds_monitoring_role = true
}
```

### Exemplo 7: Com Auto Scaling para DynamoDB

```hcl
module "iam_with_autoscaling" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  # Criar role para Application Auto Scaling
  enable_autoscaling_role = true
}
```

### Exemplo 8: Configuração Completa

```hcl
module "iam_full" {
  source = "./modules/iam"

  project_name = "meu-projeto"
  environment  = "prod"
  
  # Lambda Configuration
  lambda_in_vpc                 = true
  lambda_enable_dynamodb_access = true
  lambda_enable_s3_access       = true
  
  lambda_dynamodb_table_arns = [
    "arn:aws:dynamodb:us-east-1:123456789012:table/*"
  ]
  
  lambda_s3_bucket_arns = [
    "arn:aws:s3:::meu-bucket-*"
  ]
  
  # Lambda custom policy
  lambda_custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = "arn:aws:sqs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:*:*:secret:prod/*"
      }
    ]
  })
  
  # EC2 custom policy
  ec2_custom_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage"
        ]
        Resource = "*"
      }
    ]
  })
  
  # RDS e Auto Scaling
  enable_rds_monitoring_role = true
  enable_autoscaling_role    = true
}
```

## Variáveis Principais

### Obrigatórias
- `project_name` - Nome do projeto
- `environment` - Ambiente (dev, staging, prod)

### EC2
- `ec2_custom_policy` - Policy JSON customizada para EC2

### Lambda
- `lambda_in_vpc` - Se Lambda está em VPC (padrão: true)
- `lambda_custom_policy` - Policy JSON customizada para Lambda
- `lambda_enable_dynamodb_access` - Habilitar acesso ao DynamoDB
- `lambda_dynamodb_table_arns` - ARNs de tabelas DynamoDB
- `lambda_enable_s3_access` - Habilitar acesso ao S3
- `lambda_s3_bucket_arns` - ARNs de buckets S3

### RDS e Auto Scaling
- `enable_rds_monitoring_role` - Criar role para RDS Enhanced Monitoring
- `enable_autoscaling_role` - Criar role para Application Auto Scaling

## Outputs

### EC2
- `ec2_role_arn` - ARN da IAM role para EC2
- `ec2_role_name` - Nome da IAM role para EC2
- `ec2_instance_profile_arn` - ARN do instance profile
- `ec2_instance_profile_name` - Nome do instance profile

### Lambda
- `lambda_role_arn` - ARN da IAM role para Lambda
- `lambda_role_name` - Nome da IAM role para Lambda

### RDS
- `rds_monitoring_role_arn` - ARN da role de monitoring
- `rds_monitoring_role_name` - Nome da role de monitoring

### Auto Scaling
- `autoscaling_role_arn` - ARN da role de auto scaling
- `autoscaling_role_name` - Nome da role de auto scaling

### Admin/MFA
- `admin_group_name` - Nome do grupo de administradores IAM
- `mfa_policy_arn` - ARN da política que exige MFA

## Policies Incluídas

### EC2 Role
- **AmazonSSMManagedInstanceCore** - Permite usar Systems Manager Session Manager
- **CloudWatchAgentServerPolicy** - Permite enviar métricas ao CloudWatch
- Custom policies conforme especificado

### Lambda Role
- **AWSLambdaBasicExecutionRole** - CloudWatch Logs básico
- **AWSLambdaVPCAccessExecutionRole** - Acesso a VPC (se habilitado)
- DynamoDB access (se habilitado)
- S3 access (se habilitado)
- Custom policies conforme especificado

### RDS Enhanced Monitoring Role
- **AmazonRDSEnhancedMonitoringRole** - Métricas avançadas do RDS

### Application Auto Scaling Role
- **AWSApplicationAutoscalingDynamoDBTablePolicy** - Auto scaling do DynamoDB

## Permissões Lambda DynamoDB

Quando `lambda_enable_dynamodb_access = true`, as seguintes permissões são concedidas:

```json
{
  "Effect": "Allow",
  "Action": [
    "dynamodb:GetItem",
    "dynamodb:PutItem",
    "dynamodb:UpdateItem",
    "dynamodb:DeleteItem",
    "dynamodb:Query",
    "dynamodb:Scan",
    "dynamodb:BatchGetItem",
    "dynamodb:BatchWriteItem"
  ],
  "Resource": ["<table_arns>"]
}
```

## Permissões Lambda S3

Quando `lambda_enable_s3_access = true`, as seguintes permissões são concedidas:

```json
{
  "Effect": "Allow",
  "Action": [
    "s3:GetObject",
    "s3:PutObject",
    "s3:DeleteObject",
    "s3:ListBucket"
  ],
  "Resource": [
    "<bucket_arns>",
    "<bucket_arns>/*"
  ]
}
```

## Uso com Outros Módulos

### Com EC2

```hcl
module "iam" {
  source = "./modules/iam"
  # ... configurações
}

module "ec2" {
  source = "./modules/ec2"
  
  iam_instance_profile = module.iam.ec2_instance_profile_name
  # ... outras configurações
}
```

### Com Lambda

```hcl
module "iam" {
  source = "./modules/iam"
  
  lambda_in_vpc                 = true
  lambda_enable_dynamodb_access = true
  lambda_dynamodb_table_arns    = [module.dynamodb.table_arn]
}

module "lambda" {
  source = "./modules/lambda"
  
  lambda_role_arn = module.iam.lambda_role_arn
  # ... outras configurações
}
```

### Com RDS

```hcl
module "iam" {
  source = "./modules/iam"
  
  enable_rds_monitoring_role = true
}

module "rds" {
  source = "./modules/rds"
  
  monitoring_interval = 60
  monitoring_role_arn = module.iam.rds_monitoring_role_arn
  # ... outras configurações
}
```

## Boas Práticas

1. **Princípio do Menor Privilégio**:
   - Conceda apenas as permissões necessárias
   - Use ARNs específicos ao invés de wildcards (*)

2. **Policies Customizadas**:
   - Prefira policies customizadas para controle fino
   - Evite usar políticas AWS gerenciadas muito amplas

3. **Separação de Ambientes**:
   - Use roles diferentes para cada ambiente
   - Adicione tags para identificar facilmente

4. **Auditoria**:
   - Use AWS CloudTrail para auditar uso de roles
   - Configure alertas para ações sensíveis

5. **Rotation**:
   - Para Lambda, evite hardcoded credentials
   - Use AWS Secrets Manager ou Parameter Store

## Notas Importantes

1. **Trust Policies**: As trust policies são configuradas automaticamente para cada serviço

2. **Managed Policies**: O módulo usa policies AWS gerenciadas quando possível para facilitar manutenção

3. **Custom Policies**: Policies customizadas são inline policies anexadas diretamente às roles

4. **VPC Lambda**: Se Lambda está em VPC, a policy `AWSLambdaVPCAccessExecutionRole` é adicionada automaticamente

5. **Limites IAM**: AWS tem limites de roles e policies por conta. Verifique os limites em: https://docs.aws.amazon.com/IAM/latest/UserGuide/reference_iam-quotas.html
