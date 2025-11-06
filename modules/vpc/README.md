# Módulo Terraform - AWS VPC

Este módulo cria uma VPC (Virtual Private Cloud) completa na AWS com subnets públicas e privadas, NAT Gateways, Internet Gateway e recursos de rede.

## Recursos Criados

- ✅ VPC com CIDR customizável
- ✅ Subnets públicas em múltiplas AZs
- ✅ Subnets privadas em múltiplas AZs
- ✅ Internet Gateway para acesso público
- ✅ NAT Gateways para acesso privado à internet
- ✅ Route Tables configuradas automaticamente
- ✅ Security Group padrão
- ✅ VPC Flow Logs (opcional)
- ✅ VPC Endpoints (S3) (opcional)

## Arquitetura Criada

```
                                    Internet
                                       |
                              [Internet Gateway]
                                       |
           ┌───────────────────────────┴───────────────────────────┐
           |                         VPC                            |
           |                   (ex: 10.0.0.0/16)                   |
           |                                                        |
    ┌──────┴──────┐                                        ┌───────┴──────┐
    |  AZ 1       |                                        |  AZ 2        |
    |             |                                        |              |
    | ┌─────────┐ |                                        | ┌──────────┐ |
    | | Public  | |                                        | | Public   | |
    | | Subnet  | |                                        | | Subnet   | |
    | | 10.0.1  | |                                        | | 10.0.2   | |
    | └────┬────┘ |                                        | └────┬─────┘ |
    |      |      |                                        |      |       |
    | [NAT GW 1]  |                                        | [NAT GW 2]   |
    |      |      |                                        |      |       |
    | ┌────┴────┐ |                                        | ┌────┴─────┐ |
    | | Private | |                                        | | Private  | |
    | | Subnet  | |                                        | | Subnet   | |
    | | 10.0.10 | |                                        | | 10.0.20  | |
    | └─────────┘ |                                        | └──────────┘ |
    └─────────────┘                                        └──────────────┘
```

## Exemplos de Uso

### Exemplo 1: VPC Básica com 2 AZs

```hcl
module "vpc_basic" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 2: VPC com 3 AZs para Alta Disponibilidade

```hcl
module "vpc_high_availability" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  
  # NAT Gateway para acesso à internet de subnets privadas
  enable_nat_gateway = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 3: VPC sem NAT Gateway (Economia de Custos)

```hcl
module "vpc_no_nat" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  # Desabilitar NAT Gateway para economizar custos
  # Subnets privadas não terão acesso à internet
  enable_nat_gateway = false
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 4: VPC com Flow Logs

```hcl
module "vpc_with_flow_logs" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  # Habilitar VPC Flow Logs para auditoria
  enable_flow_logs         = true
  flow_logs_traffic_type   = "ALL"  # ACCEPT, REJECT, ou ALL
  flow_logs_retention_days = 30
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 5: VPC com VPC Endpoint para S3

```hcl
module "vpc_with_s3_endpoint" {
  source = "./modules/vpc"

  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]
  
  enable_nat_gateway = true
  
  # VPC Endpoint para S3 (tráfego privado, sem custo de NAT)
  enable_s3_endpoint = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

### Exemplo 6: VPC Completa com Todos os Recursos

```hcl
module "vpc_full" {
  source = "./modules/vpc"

  # Network Configuration
  vpc_cidr             = "10.0.0.0/16"
  availability_zones   = ["us-east-1a", "us-east-1b", "us-east-1c"]
  public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24", "10.0.30.0/24"]
  
  # DNS
  enable_dns_hostnames = true
  enable_dns_support   = true
  
  # NAT Gateway (um por AZ para alta disponibilidade)
  enable_nat_gateway = true
  
  # VPC Flow Logs
  enable_flow_logs         = true
  flow_logs_traffic_type   = "ALL"
  flow_logs_retention_days = 90
  
  # VPC Endpoints
  enable_s3_endpoint = true
  
  project_name = "meu-projeto"
  environment  = "prod"
  
  additional_tags = {
    CostCenter  = "Engineering"
    Compliance  = "PCI-DSS"
    Backup      = "Required"
  }
}
```

### Exemplo 7: VPC para Ambiente de Desenvolvimento (Mínimo)

```hcl
module "vpc_dev" {
  source = "./modules/vpc"

  vpc_cidr             = "172.16.0.0/16"
  availability_zones   = ["us-east-1a"]
  public_subnet_cidrs  = ["172.16.1.0/24"]
  private_subnet_cidrs = ["172.16.10.0/24"]
  
  # Minimal setup para dev
  enable_nat_gateway = false
  enable_flow_logs   = false
  enable_s3_endpoint = false
  
  project_name = "meu-projeto"
  environment  = "dev"
}
```

### Exemplo 8: VPC com CIDR Customizado para Rede Corporativa

```hcl
module "vpc_corporate" {
  source = "./modules/vpc"

  # CIDR não conflitante com rede corporativa
  vpc_cidr = "192.168.0.0/16"
  
  availability_zones = ["us-east-1a", "us-east-1b"]
  
  # Subnets públicas: 192.168.0.0/19 (8,190 IPs)
  public_subnet_cidrs = [
    "192.168.0.0/20",   # 192.168.0.1 - 192.168.15.254
    "192.168.16.0/20"   # 192.168.16.1 - 192.168.31.254
  ]
  
  # Subnets privadas: 192.168.32.0/19 (8,190 IPs)
  private_subnet_cidrs = [
    "192.168.32.0/20",  # 192.168.32.1 - 192.168.47.254
    "192.168.48.0/20"   # 192.168.48.1 - 192.168.63.254
  ]
  
  enable_nat_gateway = true
  enable_flow_logs   = true
  
  project_name = "meu-projeto"
  environment  = "prod"
}
```

## Variáveis Principais

### Obrigatórias
- `vpc_cidr` - CIDR block da VPC (ex: 10.0.0.0/16)
- `availability_zones` - Lista de AZs
- `public_subnet_cidrs` - Lista de CIDRs para subnets públicas
- `private_subnet_cidrs` - Lista de CIDRs para subnets privadas
- `project_name` - Nome do projeto
- `environment` - Ambiente (dev, staging, prod)

### Opcionais Importantes
- `enable_nat_gateway` - Habilitar NAT Gateway (padrão: true)
- `enable_dns_hostnames` - Habilitar DNS hostnames (padrão: true)
- `enable_dns_support` - Habilitar DNS support (padrão: true)
- `enable_flow_logs` - Habilitar VPC Flow Logs (padrão: false)
- `enable_s3_endpoint` - Habilitar VPC Endpoint para S3 (padrão: false)

## Outputs

### VPC
- `vpc_id` - ID da VPC
- `vpc_cidr` - CIDR block da VPC
- `vpc_arn` - ARN da VPC

### Subnets
- `public_subnet_ids` - Lista de IDs das subnets públicas
- `private_subnet_ids` - Lista de IDs das subnets privadas
- `public_subnet_cidrs` - Lista de CIDRs das subnets públicas
- `private_subnet_cidrs` - Lista de CIDRs das subnets privadas

### Gateways
- `internet_gateway_id` - ID do Internet Gateway
- `nat_gateway_ids` - Lista de IDs dos NAT Gateways
- `nat_gateway_public_ips` - Lista de IPs públicos dos NAT Gateways

### Route Tables
- `public_route_table_id` - ID da route table pública
- `private_route_table_ids` - Lista de IDs das route tables privadas

### Security
- `default_security_group_id` - ID do security group padrão
- `default_security_group_arn` - ARN do security group padrão

### Endpoints
- `s3_vpc_endpoint_id` - ID do VPC Endpoint para S3

## Planejamento de CIDR

### CIDRs Comuns

| CIDR | IPs Disponíveis | Uso Recomendado |
|------|-----------------|-----------------|
| /16 | 65,536 | Redes grandes, múltiplos ambientes |
| /20 | 4,096 | Rede média, ambiente único |
| /24 | 256 | Subnet típica |
| /28 | 16 | Subnet pequena (mínimo AWS) |

### Ranges Privados RFC 1918

| Range | CIDR | Uso |
|-------|------|-----|
| Classe A | 10.0.0.0/8 | Redes grandes corporativas |
| Classe B | 172.16.0.0/12 | Redes médias |
| Classe C | 192.168.0.0/16 | Redes pequenas |

### Exemplo de Divisão de VPC /16

```
VPC: 10.0.0.0/16 (65,536 IPs)

Subnets Públicas (10.0.0.0/20 - 10.0.15.254)
├── AZ1: 10.0.0.0/22   (1,024 IPs)
├── AZ2: 10.0.4.0/22   (1,024 IPs)
└── AZ3: 10.0.8.0/22   (1,024 IPs)

Subnets Privadas (10.0.16.0/20 - 10.0.31.254)
├── AZ1: 10.0.16.0/22  (1,024 IPs)
├── AZ2: 10.0.20.0/22  (1,024 IPs)
└── AZ3: 10.0.24.0/22  (1,024 IPs)

Subnets Database (10.0.32.0/20 - 10.0.47.254)
├── AZ1: 10.0.32.
