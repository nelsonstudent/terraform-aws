# Módulo Terraform - AWS EBS Volume

Este módulo cria e gerencia volumes EBS (Elastic Block Store) na AWS com recursos avançados de snapshot, monitoramento e attachment.

## Recursos Criados

- ✅ Volume EBS com configuração customizável
- ✅ Attachment automático a instâncias EC2 (opcional)
- ✅ Política de snapshot automático usando DLM (Data Lifecycle Manager)
- ✅ IAM Role para DLM (criada automaticamente se necessário)
- ✅ CloudWatch Alarms para monitoramento
- ✅ Criptografia com KMS
- ✅ Suporte a Multi-Attach (io1/io2)

## Tipos de Volume Suportados

| Tipo    | Uso Recomendado               | IOPS         | Throughput     | Tamanho        |
|---------|-------------------------------|--------------|----------------|----------------|
| **gp3** | Propósito geral (recomendado) | 3,000-16,000 | 125-1,000 MB/s | 1 GB - 16 TB   |
| **gp2** | Propósito geral (legado)      | Até 16,000   | -              | 1 GB - 16 TB   |
| **io1** | Alta performance I/O          | Até 64,000   | -              | 4 GB - 16 TB   |
| **io2** | Alta performance I/O          | Até 64,000   | -              | 4 GB - 16 TB   |
| **st1** | Throughput otimizado (HDD)    | -            | Até 500 MB/s   | 125 GB - 16 TB |
| **sc1** | Cold HDD (baixo custo)        | -            | Até 250 MB/s   | 125 GB - 16 TB |

## Exemplos de Uso

### Exemplo 1: Volume gp3 Básico

```hcl
module "ebs_basic" {
  source = "./modules/ebs"

  project_name      = "meu-projeto"
  environment       = "prod"
  availability_zone = "us-east-1a"
  size              = 100
  volume_type       = "gp3"
  iops              = 3000
  throughput        = 125
}
```

### Exemplo 2: Volume com Attachment Automático

```hcl
module "ebs_attached" {
  source = "./modules/ebs"

  project_name      = "meu-projeto"
  environment       = "prod"
  availability_zone = "us-east-1a"
  size              = 200
  volume_type       = "gp3"
  
  # Anexar a uma instância EC2
  instance_id = "i-1234567890abcdef0"
  device_name = "/dev/sdf"
}
```

### Exemplo 3: Volume com Snapshots Automáticos

```hcl
module "ebs_with_snapshots" {
  source = "./modules/ebs"

  project_name      = "meu-projeto"
  environment       = "prod"
  availability_zone = "us-east-1a"
  size              = 500
  volume_type       = "gp3"
  
  # Habilitar snapshots automáticos
  enable_snapshot_lifecycle = true
  snapshot_interval         = 24
  snapshot_interval_unit    = "HOURS"
  snapshot_times            = ["03:00"]
  snapshot_retention_count  = 14  # Manter 14 snapshots
}
```

### Exemplo 4: Volume io2 de Alta Performance com Multi-Attach

```hcl
module "ebs_high_performance" {
  source = "./modules/ebs"

  project_name      = "meu-projeto"
  environment       = "prod"
  availability_zone = "us-east-1a"
  size              = 1000
  volume_type       = "io2"
  iops              = 32000
  
  # Habilitar multi-attach (múltiplas instâncias podem usar o volume)
  multi_attach_enabled = true
}
```

### Exemplo 5: Volume Completo com Monitoramento

```hcl
module "ebs_full" {
  source = "./modules/ebs"

  project_name      = "meu-projeto"
  environment       = "prod"
  availability_zone = "us-east-1a"
  size              = 300
  volume_type       = "gp3"
  iops              = 5000
  throughput        = 250
  
  # Criptografia
  encrypted  = true
  kms_key_id = "arn:aws:kms:us-east-1:123456789012:key/12345678-1234-1234-1234-123456789012"
  
  # Attachment
  instance_id = module.ec2.instance_id
  device_name = "/dev/sdf"
  
  # Snapshots automáticos
  enable_snapshot_lifecycle = true
  snapshot_interval         = 12
  snapshot_interval_unit    = "HOURS"
  snapshot_times            = ["03:00", "15:00"]
  snapshot_retention_count  = 30
  
  # Monitoramento
  enable_cloudwatch_alarms  = true
  burst_balance_threshold   = 20
  idle_time_threshold       = 300
  read_ops_threshold        = 50000
  write_ops_threshold       = 50000
  
  # Tags adicionais
  additional_tags = {
    Application = "Database"
    CostCenter  = "Engineering"
    Backup      = "Daily"
  }
}
```

### Exemplo 6: Volume a partir de Snapshot

```hcl
module "ebs_from_snapshot" {
  source = "./modules/ebs"

  project_name      = "meu-projeto"
  environment       = "prod"
  availability_zone = "us-east-1a"
  volume_type       = "gp3"
  
  # Criar volume a partir de snapshot existente
  snapshot_id = "snap-1234567890abcdef0"
  
  # O tamanho será herdado do snapshot, mas pode ser aumentado
  size = 150  # Deve ser >= tamanho do snapshot
}
```

## Variáveis Principais

### Obrigatórias
- `project_name` - Nome do projeto
- `environment` - Ambiente (dev, staging, prod)
- `availability_zone` - AZ onde criar o volume
- `size` - Tamanho em GB

### Opcionais Importantes
- `volume_type` - Tipo do volume (padrão: gp3)
- `iops` - IOPS provisionados (para gp3, io1, io2)
- `throughput` - Throughput em MB/s (para gp3)
- `encrypted` - Habilitar criptografia (padrão: true)
- `instance_id` - ID da instância para attachment automático
- `enable_snapshot_lifecycle` - Habilitar snapshots automáticos
- `enable_cloudwatch_alarms` - Habilitar alarmes de monitoramento

## Outputs

### Informações do Volume
- `volume_id` - ID do volume
- `volume_arn` - ARN do volume
- `volume_size` - Tamanho em GB
- `volume_type` - Tipo do volume

### Informações de Attachment
- `attachment_id` - ID do attachment
- `attachment_device_name` - Nome do device
- `is_attached` - Se está anexado

### Snapshots
- `snapshot_policy_id` - ID da política DLM
- `snapshot_policy_arn` - ARN da política DLM

### Alarmes
- `idle_alarm_arn` - ARN do alarme de idle
- `burst_balance_alarm_arn` - ARN do alarme de burst balance
- `read_ops_alarm_arn` - ARN do alarme de operações de leitura
- `write_ops_alarm_arn` - ARN do alarme de operações de escrita

## Notas Importantes

1. **Multi-Attach**: Só funciona com io1/io2 na mesma AZ
2. **Criptografia**: Por padrão está habilitada, recomendado para produção
3. **Snapshots**: O DLM cria snapshots automaticamente e gerencia a retenção
4. **IOPS e Throughput**: 
   - gp3: 3,000 IOPS base (grátis), até 16,000 (pago)
   - gp3:
