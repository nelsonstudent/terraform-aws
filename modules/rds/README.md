# Módulo Terraform - AWS RDS

Este módulo cria e gerencia instâncias RDS (Relational Database Service) na AWS com configuração completa de backup, monitoramento e alta disponibilidade.

## Recursos Criados

- ✅ Instância RDS com engine configurável
- ✅ DB Subnet Group
- ✅ DB Parameter Group (opcional)
- ✅ DB Option Group (opcional)
- ✅ Backups automáticos
- ✅ Multi-AZ para alta disponibilidade (opcional)
- ✅ Performance Insights (opcional)
- ✅ Enhanced Monitoring (opcional)
- ✅ CloudWatch Alarms (opcional)
- ✅ Read Replicas (opcional)

## Engines Suportadas

| Engine | Versões | Uso |
|--------|---------|-----|
| **MySQL** | 5.7, 8.0 | Aplicações web, WordPress |
| **PostgreSQL** | 12, 13, 14, 15, 16 | Analytics, JSON, geoespacial |
| **MariaDB** | 10.6, 10.11 | Drop-in MySQL replacement |
| **Oracle** | 19c, 21c | Enterprise applications |
| **SQL Server** | 2016, 2019, 2022 | Microsoft stack |
| **Aurora MySQL** | 5.7, 8.0 | Alta performance MySQL |
| **Aurora PostgreSQL** | 11-15 | Alta performance PostgreSQL |

## Exemplos de Uso

### Exemplo 1: MySQL Básico

```hcl
module "rds_mysql_basic" {
  source = "./modules/rds"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"
  
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  
  db_name  = "mydb"
  username = "admin"
  password = var.db_password  # Use variável sensível
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 7
  skip_final_snapshot     = false
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: PostgreSQL para Produção

```hcl
module "rds_postgres_prod" {
  source = "./modules/rds"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.large"
  
  allocated_storage     = 100
  max_allocated_storage = 1000  # Auto scaling até 1TB
  storage_type          = "gp3"
  iops                  = 3000
  storage_encrypted     = true
  
  db_name  = "production"
  username = "dbadmin"
  password = var.db_password
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # Alta Disponibilidade
  multi_az = true
  
  # Backups
  backup_retention_period = 30
  backup_window           = "03:00-04:00"
  maintenance_window      = "sun:04:00-sun:05:00"
  
  # Monitoramento
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  monitoring_interval             = 60
  monitoring_role_arn             = module.iam.rds_monitoring_role_arn
  performance_insights_enabled    = true
  
  # Segurança
  deletion_protection = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 3: MySQL com Parameter Group Customizado

```hcl
module "rds_mysql_custom" {
  source = "./modules/rds"

  engine         = "mysql"
  engine_version = "8.0.35"
  instance_class = "db.t3.medium"
  
  allocated_storage = 50
  storage_encrypted = true
  
  db_name  = "appdb"
  username = "admin"
  password = var.db_password
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # Parameter Group customizado
  create_parameter_group  = true
  parameter_group_family  = "mysql8.0"
  
  parameters = [
    {
      name  = "max_connections"
      value = "200"
    },
    {
      name  = "innodb_buffer_pool_size"
      value = "{DBInstanceClassMemory*3/4}"
    },
    {
      name  = "slow_query_log"
      value = "1"
    },
    {
      name  = "long_query_time"
      value = "2"
    }
  ]
  
  backup_retention_period = 14
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 4: PostgreSQL com Performance Insights

```hcl
module "rds_postgres_insights" {
  source = "./modules/rds"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.r6g.xlarge"
  
  allocated_storage = 200
  storage_type      = "io1"
  iops              = 5000
  storage_encrypted = true
  
  db_name  = "analytics"
  username = "postgres"
  password = var.db_password
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  multi_az = true
  
  # Performance Insights
  performance_insights_enabled          = true
  performance_insights_retention_period = 731  # 2 anos
  
  # Enhanced Monitoring
  monitoring_interval = 15
  monitoring_role_arn = module.iam.rds_monitoring_role_arn
  
  # CloudWatch Logs
  enabled_cloudwatch_logs_exports = ["postgresql", "upgrade"]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 5: Read Replica

```hcl
# Instância Principal
module "rds_primary" {
  source = "./modules/rds"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.r6g.large"
  
  allocated_storage = 100
  storage_encrypted = true
  
  db_name  = "maindb"
  username = "admin"
  password = var.db_password
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 7
  
  project_name = "meu-projeto"
  environment  = "prod"
}

# Read Replica
module "rds_replica" {
  source = "./modules/rds"

  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.r6g.large"
  
  # Replica da instância principal
  replicate_source_db = module.rds_primary.instance_arn
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # Réplica não precisa de username/password
  skip_final_snapshot = true
  
  project_name = "meu-projeto"
  environment  = "prod-replica"
}
```

### Exemplo 6: MariaDB com Option Group

```hcl
module "rds_mariadb" {
  source = "./modules/rds"

  engine               = "mariadb"
  engine_version       = "10.11.6"
  instance_class       = "db.t3.medium"
  major_engine_version = "10.11"
  
  allocated_storage = 50
  storage_encrypted = true
  
  db_name  = "mariadb"
  username = "admin"
  password = var.db_password
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # Option Group
  create_option_group = true
  
  options = [
    {
      option_name = "MARIADB_AUDIT_PLUGIN"
      option_settings = [
        {
          name  = "SERVER_AUDIT_EVENTS"
          value = "CONNECT"
        }
      ]
    }
  ]
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 7: SQL Server Express

```hcl
module "rds_sqlserver" {
  source = "./modules/rds"

  engine         = "sqlserver-ex"
  engine_version = "15.00.4322.2.v1"
  instance_class = "db.t3.small"
  
  allocated_storage = 20
  storage_type      = "gp3"
  storage_encrypted = true
  
  # SQL Server não usa db_name
  username = "admin"
  password = var.db_password
  
  # Timezone para SQL Server
  timezone = "UTC"
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 7
  
  # SQL Server requer license
  # ex: enterprise-edition, standard-edition, express-edition
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 8: Oracle Standard Edition

```hcl
module "rds_oracle" {
  source = "./modules/rds"

  engine         = "oracle-se2"
  engine_version = "19.0.0.0.ru-2023-10.rur-2023-10.r1"
  instance_class = "db.t3.medium"
  
  allocated_storage = 100
  storage_type      = "gp3"
  storage_encrypted = true
  
  # Oracle usa username diferente
  username = "oracleadmin"
  password = var.db_password
  
  # Character set para Oracle
  character_set_name = "AL32UTF8"
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  backup_retention_period = 14
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 9: RDS com CloudWatch Alarms

```hcl
module "rds_monitored" {
  source = "./modules/rds"

  engine         = "postgres"
  engine_version = "15.4"
  instance_class = "db.t3.medium"
  
  allocated_storage = 50
  storage_encrypted = true
  
  db_name  = "monitored"
  username = "postgres"
  password = var.db_password
  
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  
  # CloudWatch Alarms
  enable_cloudwatch_alarms      = true
  cpu_alarm_threshold           = 80
  storage_alarm_threshold       = 10737418240  # 10 GB
  connection_alarm_threshold    = 80
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 10: RDS Completo para Produção

```hcl
module "rds_production" {
  source = "./modules/rds"

  # Engine Configuration
  engine               = "postgres"
  engine_version       = "15.4"
  instance_class       = "db.r6g.2xlarge"
  major_engine_version = "15"
  
  # Storage
  allocated_storage     = 500
  max_allocated_storage = 2000  # Auto scaling até 2TB
  storage_type          = "io2"
  iops                  = 10000
  storage_encrypted     = true
  kms_key_id            = aws_kms_key.rds.arn
  
  # Database
  db_name  = "production"
  username = "dbadmin"
  password = var.db_password
  port     = 5432
  
  # Network
  subnet_ids             = module.vpc.private_subnet_ids
  vpc_security_group_ids = [aws_security_group.rds.id]
  publicly_accessible    = false
  
  # High Availability
  multi_az = true
  
  # Backup & Maintenance
  backup_retention_period   = 35  # Máximo
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"
  copy_tags_to_snapshot     = true
  skip_final_snapshot       = false
  auto_minor_version_upgrade = true
  
  # Monitoring
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  monitoring_interval                   = 15
  monitoring_role_arn                   = module.iam.rds_monitoring_role_arn
  performance_insights_enabled          = true
  performance_insights_retention_period = 731
  
  # Security
  deletion_protection = true
  
  # Parameter Group
  create_parameter_group = true
  parameter_group_family = "postgres15"
  
  parameters = [
    {
      name  = "shared_preload_libraries"
      value = "pg_stat_statements"
    },
    {
      name  = "log_statement"
      value = "all"
    },
    {
      name  = "log_min_duration_statement"
      value = "1000"  # Log queries > 1s
    }
  ]
  
  # CloudWatch Alarms
  enable_cloudwatch_alarms   = true
  cpu_alarm_threshold        = 75
  storage_alarm_threshold    = 53687091200  # 50 GB
  connection_alarm_threshold = 200
  
  project_name = "meu-projeto"
  environment  = "prod"
  
  additional_tags = {
    Application = "Core"
    CostCenter  = "Engineering"
    Backup      = "Critical"
    Compliance  = "GDPR"
  }
}
```

## Variáveis Principais

### Obrigatórias
- `engine` - Engine do banco (mysql, postgres, mariadb, etc)
- `engine_version` - Versão da engine
- `instance_class` - Classe da instância
- `allocated_storage` - Storage inicial em GB
- `db_name` - Nome do database
- `username` - Username master
- `password` - Password master (use variável sensível)
- `subnet_ids` - IDs das subnets
- `vpc_security_group_ids` - IDs dos security groups
- `project_name` - Nome do projeto
- `environment` - Ambiente

### Storage
- `max_allocated_storage` - Storage máximo para auto scaling
- `storage_type` - gp2, gp3, io1, io2
- `iops` - IOPS provisionados (io1/io2)
- `storage_encrypted` - Criptografar storage (padrão: true)
- `kms_key_id` - ARN da chave KMS

### Alta Disponibilidade
- `multi_az` - Habilitar Multi-AZ (padrão: false)
- `availability_zone` - AZ específica (apenas single-AZ)

### Backup
- `backup_retention_period` - Dias de retenção (0-35)
- `backup_window` - Janela de backup
- `skip_final_snapshot` - Pular snapshot final

### Monitoring
- `monitoring_interval` - Intervalo de enhanced monitoring (0, 1, 5, 10, 15, 30, 60)
- `performance_insights_enabled` - Habilitar Performance Insights
- `enabled_cloudwatch_logs_exports` - Logs para exportar

### Parameter/Option Groups
- `create_parameter_group` - Criar parameter group
- `parameters` - Lista de parâmetros customizados
- `create_option_group` - Criar option group
- `options` - Lista de options

## Outputs

### Instance
- `instance_id` - ID da instância
- `instance_arn` - ARN da instância
- `endpoint` - Endpoint de conexão
- `address` - Hostname do RDS
- `port` - Porta do RDS

### Database
- `database_name` - Nome do database
- `username` - Username master
- `engine` - Engine do banco
- `engine_version` - Versão da engine

### Network
- `db_subnet_group_name` - Nome do subnet group
- `parameter_group_name` - Nome do parameter group

### Monitoring
- `cpu_alarm_arn` - ARN do alarme de CPU
- `storage_alarm_arn` - ARN do alarme de storage
- `connection_alarm_arn` - ARN do alarme de conexões

### Connection String
- `connection_string` - String JDBC de conexão

## Classes de Instância

### Propósito Geral (t-family)
| Classe | vCPU | RAM | Uso |
|--------|------|-----|-----|
| db.t3.micro | 2 | 1 GB | Dev, testes |
| db.t3.small | 2 | 2 GB | Apps pequenos |
| db.t3.medium | 2 | 4 GB | Apps médios |
| db.t3.large | 2 | 8 GB | Apps grandes |

### Memória Otimizada (r-family)
| Classe | vCPU | RAM | Uso |
|--------|------|-----|-----|
| db.r6g.large | 2 | 16 GB | Databases médios |
| db.r6g.xlarge | 4 | 32 GB | Databases grandes |
| db.r6g.2xlarge | 8 | 64 GB | Alta performance |
| db.r6g.4xlarge | 16 | 128 GB | Enterprise |

### Burstable (t-family) - Graviton2
| Classe | vCPU | RAM | Custo |
|--------|------|-----|-------|
| db.t4g.micro | 2 | 1 GB | Mais barato |
| db.t4g.small | 2 | 2 GB | 20% economia |
| db.t4g.medium | 2 | 4 GB | vs t3 |

## Storage Types

| Tipo | IOPS | Throughput | Uso |
|------|------|------------|-----|
| **gp2** | 3 IOPS/GB (max 16,000) | - | Legado |
| **gp3** | 3,000 base (max 16,000) | 125-1000 MB/s | Recomendado |
| **io1** | Até 64,000 | - | Alta performance |
| **io2** | Até 64,000 | - | Alta durabilidade |

## Portas Padrão

| Engine | Porta |
|--------|-------|
| MySQL | 3306 |
| PostgreSQL | 5432 |
| MariaDB | 3306 |
| Oracle | 1521 |
| SQL Server | 1433 |

## Multi-AZ vs Read Replica

### Multi-AZ
- **Propósito**: Alta disponibilidade
- **Failover**: Automático (1-2 minutos)
- **Replicação**: Síncrona
- **Endpoint**: Único endpoint
- **Uso**: Disaster recovery

### Read Replica
- **Propósito**: Escalabilidade de leitura
- **Failover**: Manual (promoção)
- **Replicação**: Assíncrona
- **Endpoint**: Endpoint separado
- **Uso**: Distribuir carga de leitura

## Connection Strings

### MySQL
```
mysql -h <endpoint> -P 3306 -u <username> -p<password> <dbname>
```

### PostgreSQL
```
psql -h <endpoint> -p 5432 -U <username> -d <dbname>
```

### Connection String (JDBC)
```
jdbc:mysql://<endpoint>:3306/<dbname>
jdbc:postgresql://<endpoint>:5432/<dbname>
```

## Parameter Groups Comuns

### MySQL Performance
```hcl
parameters = [
  {
    name  = "max_connections"
    value = "200"
  },
  {
    name  = "innodb_buffer_pool_size"
    value = "{DBInstanceClassMemory*3/4}"
  }
]
```

### PostgreSQL Performance
```hcl
parameters = [
  {
    name  = "shared_buffers"
    value = "{DBInstanceClassMemory/4096}"
  },
  {
    name  = "effective_cache_size"
    value = "{DBInstanceClassMemory*3/4096}"
  }
]
```

## Boas Práticas

1. **Multi-AZ**: Sempre use em produção
2. **Backups**: Configure retention adequado (7-35 dias)
3. **Encryption**: Sempre criptografe em produção
4. **Security Groups**: Permita apenas IPs necessários
5. **Parameter Groups**: Customize para seu workload
6. **Monitoring**: Habilite Performance Insights e Enhanced Monitoring
7. **Maintenance Window**: Configure fora do horário de pico
8. **Storage**: Use gp3 para melhor custo-benefício
9. **Auto Scaling**: Configure max_allocated_storage
10. **Secrets**: Use AWS Secrets Manager para passwords

## Custos

### Componentes de Custo
1. **Instância**: Por hora de execução
2. **Storage**: Por GB-mês
3. **IOPS**: Provisionados (io1/io2)
4. **Backup**: Storage além do retention period
5. **Data Transfer**: Tráfego de saída
6. **Multi-AZ**: ~2x custo da instância

### Otimização
- Use instâncias Graviton2 (t4g, r6g) - 20% mais barato
- Reserved Instances - até 70% de desconto
- gp3 vs gp2 - mesma performance, menor custo
- Delete snapshots antigos

## Maintenance & Upgrades

### Minor Version Upgrades
- Automáticos se `auto_minor_version_upgrade = true`
- Aplicados durante maintenance window
- Sem downtime significativo

### Major Version Upgrades
- Sempre manuais
- Requer planejamento
- Teste em ambiente não-produção primeiro

## Troubleshooting

### Conexão Lenta
1. Verificar security groups
2. Verificar parameter groups (max_connections)
3. Habilitar Performance Insights
4. Verificar IOPS

### Alto CPU
1. Otimizar queries (slow query log)
2. Adicionar índices
3. Aumentar instance class
4. Implementar read replicas

### Storage Cheio
1. Configurar max_allocated_storage
2. Limpar logs antigos
3. Arquivar dados históricos
4. Aumentar retention

## Segurança

1. **Network**: Sempre em subnets privadas
2. **Encryption**: At-rest e in-transit
3. **IAM**: Use IAM database authentication
4. **Secrets**: AWS Secrets Manager
5. **Audit**: Habilitar logs de auditoria
6. **Backups**: Criptografar backups
7. **SSL/TLS**: Forçar conexões seguras

## Limites AWS

- **DB Instances**: 40 por região
- **Read Replicas**: 5 por master
- **Storage**: Até 64 TB (depende da engine)
- **Backup Retention**: Máximo 35 dias
- **Parameter Groups**: 20 por região
- **Option Groups**: 20 por região
