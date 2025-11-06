# Módulo Terraform - AWS Lambda

Este módulo cria e gerencia funções Lambda na AWS com configuração completa de VPC, monitoramento, triggers e Function URLs.

## Recursos Criados

- ✅ Função Lambda configurável
- ✅ CloudWatch Log Group
- ✅ Lambda Alias (opcional)
- ✅ Lambda Permissions para triggers
- ✅ Event Source Mappings (DynamoDB Streams, SQS, Kinesis)
- ✅ Lambda Function URL (opcional)
- ✅ CloudWatch Alarms (opcional)
- ✅ Suporte a Layers
- ✅ X-Ray Tracing

## Runtimes Suportados

| Runtime | Versão | Linguagem |
|---------|--------|-----------|
| python3.12 | Python 3.12 | Python |
| python3.11 | Python 3.11 | Python |
| nodejs20.x | Node.js 20 | JavaScript/TypeScript |
| nodejs18.x | Node.js 18 | JavaScript/TypeScript |
| java21 | Java 21 | Java |
| java17 | Java 17 | Java |
| dotnet8 | .NET 8 | C# |
| ruby3.2 | Ruby 3.2 | Ruby |
| go1.x | Go 1.x | Go |

## Exemplos de Uso

### Exemplo 1: Função Lambda Básica

```hcl
module "lambda_basic" {
  source = "./modules/lambda"

  function_name    = "minha-funcao"
  runtime          = "python3.11"
  handler          = "index.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda_function.zip"
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: Lambda com Variáveis de Ambiente

```hcl
module "lambda_with_env" {
  source = "./modules/lambda"

  function_name    = "api-handler"
  runtime          = "python3.11"
  handler          = "app.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Variáveis de ambiente
  environment_vars = {
    DB_HOST     = module.rds.endpoint
    DB_NAME     = "mydb"
    TABLE_NAME  = module.dynamodb.table_name
    BUCKET_NAME = module.s3.bucket_name
    ENVIRONMENT = "production"
  }
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 3: Lambda em VPC

```hcl
module "lambda_in_vpc" {
  source = "./modules/lambda"

  function_name    = "vpc-lambda"
  runtime          = "python3.11"
  handler          = "index.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # VPC Configuration
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 4: Lambda com Configuração de Performance

```hcl
module "lambda_performance" {
  source = "./modules/lambda"

  function_name    = "heavy-processing"
  runtime          = "python3.11"
  handler          = "processor.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Performance
  memory_size             = 1024  # MB
  timeout                 = 300   # 5 minutos
  ephemeral_storage_size  = 2048  # 2 GB
  architecture            = "arm64" # Graviton2 (mais barato)
  
  # Concurrency
  reserved_concurrent_executions = 10
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 5: Lambda com DynamoDB Streams

```hcl
module "lambda_dynamodb_stream" {
  source = "./modules/lambda"

  function_name    = "stream-processor"
  runtime          = "python3.11"
  handler          = "stream.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [module.vpc.default_security_group_id]
  
  # Event Source Mapping - DynamoDB Streams
  event_source_mappings = [
    {
      event_source_arn  = module.dynamodb.table_stream_arn
      starting_position = "LATEST"
      batch_size        = 100
      enabled           = true
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 6: Lambda com API Gateway Trigger

```hcl
module "lambda_api" {
  source = "./modules/lambda"

  function_name    = "api-endpoint"
  runtime          = "nodejs20.x"
  handler          = "index.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Permitir API Gateway invocar a função
  allowed_triggers = [
    {
      service_name = "apigateway"
      source_arn   = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 7: Lambda com Function URL

```hcl
module "lambda_function_url" {
  source = "./modules/lambda"

  function_name    = "http-handler"
  runtime          = "python3.11"
  handler          = "api.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Function URL (HTTP endpoint direto)
  create_function_url   = true
  function_url_auth_type = "NONE"  # Público
  
  function_url_cors = {
    allow_origins     = ["https://meusite.com"]
    allow_methods     = ["GET", "POST"]
    allow_headers     = ["Content-Type", "Authorization"]
    max_age           = 3600
  }
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 8: Lambda com Layers

```hcl
module "lambda_with_layers" {
  source = "./modules/lambda"

  function_name    = "app-with-deps"
  runtime          = "python3.11"
  handler          = "app.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Lambda Layers (bibliotecas compartilhadas)
  layers = [
    "arn:aws:lambda:us-east-1:123456789012:layer:pandas:1",
    "arn:aws:lambda:us-east-1:123456789012:layer:requests:2"
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 9: Lambda com X-Ray Tracing

```hcl
module "lambda_traced" {
  source = "./modules/lambda"

  function_name    = "traced-function"
  runtime          = "python3.11"
  handler          = "app.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # X-Ray Tracing
  tracing_mode = "Active"
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 10: Lambda com Dead Letter Queue

```hcl
module "lambda_with_dlq" {
  source = "./modules/lambda"

  function_name    = "reliable-processor"
  runtime          = "python3.11"
  handler          = "processor.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Dead Letter Queue para erros
  dead_letter_target_arn = aws_sqs_queue.dlq.arn
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 11: Lambda com Alias e Weighted Routing

```hcl
module "lambda_with_alias" {
  source = "./modules/lambda"

  function_name    = "versioned-function"
  runtime          = "python3.11"
  handler          = "app.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Criar alias com roteamento ponderado
  create_alias              = true
  alias_name                = "prod"
  alias_function_version    = "2"
  
  # 90% do tráfego para v2, 10% para v3 (canary deployment)
  alias_routing_additional_version_weights = {
    "3" = 0.1
  }
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 12: Lambda Completa com Monitoramento

```hcl
module "lambda_full" {
  source = "./modules/lambda"

  function_name    = "production-api"
  runtime          = "python3.11"
  handler          = "api.handler"
  lambda_role_arn  = module.iam.lambda_role_arn
  source_code_path = "./lambda.zip"
  
  # Performance
  memory_size             = 512
  timeout                 = 60
  ephemeral_storage_size  = 1024
  architecture            = "arm64"
  
  # VPC
  subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids = [aws_security_group.lambda.id]
  
  # Environment
  environment_vars = {
    DB_HOST     = module.rds.endpoint
    TABLE_NAME  = module.dynamodb.table_name
    BUCKET_NAME = module.s3.bucket_name
    LOG_LEVEL   = "INFO"
  }
  
  # Logging
  log_retention_days = 30
  log_format         = "JSON"
  
  # Tracing
  tracing_mode = "Active"
  
  # Dead Letter Queue
  dead_letter_target_arn = aws_sqs_queue.dlq.arn
  
  # Concurrency
  reserved_concurrent_executions = 50
  
  # Layers
  layers = [
    aws_lambda_layer_version.dependencies.arn
  ]
  
  # Monitoring
  enable_cloudwatch_alarms  = true
  error_alarm_threshold     = 5
  throttle_alarm_threshold  = 3
  
  # Triggers
  allowed_triggers = [
    {
      service_name = "apigateway"
      source_arn   = "${aws_api_gateway_rest_api.main.execution_arn}/*/*"
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
  
  additional_tags = {
    Application = "API"
    CostCenter  = "Engineering"
  }
}
```

## Variáveis Principais

### Obrigatórias
- `function_name` - Nome da função
- `runtime` - Runtime (python3.11, nodejs20.x, etc)
- `handler` - Handler da função
- `lambda_role_arn` - ARN da IAM role
- `source_code_path` - Caminho para o arquivo .zip
- `project_name` - Nome do projeto
- `environment` - Ambiente

### Performance
- `memory_size` - Memória em MB (128-10240, padrão: 128)
- `timeout` - Timeout em segundos (1-900, padrão: 30)
- `ephemeral_storage_size` - Storage temporário em MB (512-10240)
- `architecture` - x86_64 ou arm64
- `reserved_concurrent_executions` - Limite de execuções simultâneas

### VPC
- `subnet_ids` - IDs das subnets privadas
- `security_group_ids` - IDs dos security groups

### Environment
- `environment_vars` - Map de variáveis de ambiente

### Logging
- `log_retention_days` - Dias de retenção dos logs (padrão: 7)
- `log_format` - Text ou JSON

### Tracing
- `tracing_mode` - PassThrough ou Active

### Advanced
- `layers` - Lista de ARNs de layers
- `dead_letter_target_arn` - ARN do SNS/SQS para DLQ
- `create_function_url` - Criar Function URL
- `create_alias` - Criar alias

## Outputs

### Function
- `function_name` - Nome da função
- `function_arn` - ARN da função
- `invoke_arn` - ARN de invocação
- `version` - Versão da função

### Logs
- `log_group_name` - Nome do Log Group
- `log_group_arn` - ARN do Log Group

### URL
- `function_url` - URL da função (se criada)

### Alias
- `alias_arn` - ARN do alias
- `alias_invoke_arn` - ARN de invocação do alias

### Monitoring
- `error_alarm_arn` - ARN do alarme de erros
- `throttle_alarm_arn` - ARN do alarme de throttling

## Relação Memória x CPU

Lambda aloca CPU proporcionalmente à memória:

| Memória | vCPU |
|---------|------|
| 128 MB | 0.08 vCPU |
| 512 MB | 0.33 vCPU |
| 1024 MB | 0.67 vCPU |
| 1536 MB | 1 vCPU |
| 3008 MB | 2 vCPU |
| 10240 MB | 6 vCPU |

## Arquiteturas

### x86_64 (Intel/AMD)
- Compatível com todas as bibliotecas
- Maior ecossistema de layers

### arm64 (AWS Graviton2)
- Até 34% mais barato
- Até 19% melhor performance
- Requer recompilação de dependências nativas

## Event Source Mappings

### DynamoDB Streams
```hcl
event_source_mappings = [
  {
    event_source_arn  = module.dynamodb.table_stream_arn
    starting_position = "LATEST"  # TRIM_HORIZON ou LATEST
    batch_size        = 100
    enabled           = true
  }
]
```

### SQS Queue
```hcl
event_source_mappings = [
  {
    event_source_arn = aws_sqs_queue.main.arn
    batch_size       = 10
    enabled          = true
  }
]
```

### Kinesis Stream
```hcl
event_source_mappings = [
  {
    event_source_arn  = aws_kinesis_stream.main.arn
    starting_position = "LATEST"
    batch_size        = 100
    enabled           = true
  }
]
```

## Lambda Layers

Layers permitem compartilhar código entre funções:

```bash
# Estrutura de um Layer
layer.zip
└── python/
    └── lib/
        └── python3.11/
            └── site-packages/
                ├── requests/
                └── boto3/
```

Criar layer:
```hcl
resource "aws_lambda_layer_version" "dependencies" {
  filename   = "layer.zip"
  layer_name = "python-dependencies"
  
  compatible_runtimes = ["python3.11"]
}
```

## Function URLs

Function URLs fornecem endpoint HTTP direto:

```
https://<url-id>.lambda-url.<region>.on.aws/
```

### Tipos de Auth
- **NONE**: Público, sem autenticação
- **AWS_IAM**: Requer autenticação AWS SigV4

## CloudWatch Logs Insights Queries

### Erros nas últimas 24h
```
fields @timestamp, @message
| filter @type = "ERROR"
| sort @timestamp desc
```

### Duração média por hora
```
fields @timestamp, @duration
| stats avg(@duration) as avg_duration by bin(5m)
```

### Erros específicos
```
fields @timestamp, @message
| filter @message like /Exception/
| sort @timestamp desc
```

## Boas Práticas

1. **Timeout**: Configure adequadamente, nem muito curto nem muito longo
2. **Memória**: Teste diferentes valores, mais memória = mais CPU
3. **VPC**: Use apenas se necessário (adiciona latência)
4. **Layers**: Compartilhe dependências comuns via layers
5. **Environment Variables**: Use para configuração, não para secrets
6. **Dead Letter Queue**: Configure para capturar falhas
7. **X-Ray**: Habilite para debugging em produção
8. **Reserved Concurrency**: Configure para evitar throttling
9. **Logs**: Use log format JSON para facilitar parsing
10. **Versioning**: Use aliases para deployments graduais

## Limites do Lambda

- **Timeout**: Máximo 15 minutos (900 segundos)
- **Memória**: 128 MB a 10,240 MB
- **Payload**: 6 MB síncrono, 256 KB assíncrono
- **Deployment package**: 50 MB (comprimido), 250 MB (descomprimido)
- **Ephemeral storage (/tmp)**: 512 MB a 10,240 MB
- **Concurrent executions**: 1,000 por região (pode ser aumentado)
- **Environment variables**: 4 KB total

## Custo

Lambda cobra por:
1. **Requests**: $0.20 por 1 milhão de requests
2. **Duration**: $0.0000166667 por GB-segundo (x86_64)
3. **Duration**: $0.0000133334 por GB-segundo (arm64) - 20% mais barato

### Exemplo de Custo
Função com 512 MB executando 1 milhão de vezes por 200ms:
- Requests: $0.20
- Duration: 1M × 0.2s × 0.5GB × $0.0000166667 = $1.67
- **Total**: $1.87/mês

## Debugging

### Logs locais
```python
import json
import logging

logger = logging.getLogger()
logger.setLevel(logging.INFO)

def handler(event, context):
    logger.info(f"Event: {json.dumps(event)}")
    # seu código aqui
```

### Testing local com SAM
```bash
sam local invoke MyFunction -e event.json
```

## Segurança

1. **IAM Role**: Siga princípio do menor privilégio
2. **Secrets**: Use AWS Secrets Manager ou Parameter Store
3. **VPC**: Isole em VPC se acessar recursos privados
4. **Environment Variables**: Criptografe variáveis sensíveis
5. **IMDSv2**: Não aplicável (Lambda não tem IMDS)
6. **X-Ray**: Não exponha dados sensíveis nos traces
