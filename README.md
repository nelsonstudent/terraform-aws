# Infraestrutura AWS com Terraform - Módulos Reutilizáveis

[![Terraform](https://img.shields.io/badge/Terraform-%3E%3D1.0-623CE4?logo=terraform)](https://www.terraform.io/)
[![AWS](https://img.shields.io/badge/AWS-Provider%205.x-FF9900?logo=amazon-aws)](https://aws.amazon.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)

Coleção completa de módulos Terraform para provisionar infraestrutura AWS de forma modular, reutilizável e seguindo as melhores práticas.

## 📋 Índice

- [Visão Geral](#visão-geral)
- [Arquitetura](#arquitetura)
- [Módulos Disponíveis](#módulos-disponíveis)
- [Pré-requisitos](#pré-requisitos)
- [Início Rápido](#início-rápido)
- [Estrutura do Projeto](#estrutura-do-projeto)
- [Uso](#uso)
- [Exemplos](#exemplos)
- [Variáveis](#variáveis)
- [Outputs](#outputs)
- [Custos Estimados](#custos-estimados)
- [Boas Práticas](#boas-práticas)
- [Troubleshooting](#troubleshooting)
- [Contribuindo](#contribuindo)

## 🎯 Visão Geral

Este projeto fornece módulos Terraform prontos para uso para provisionar e gerenciar recursos AWS. Cada módulo é independente, testado e documentado, permitindo que você construa sua infraestrutura de forma incremental e mantível.

### Características Principais

✅ **Modular**: Cada serviço AWS em seu próprio módulo  
✅ **Reutilizável**: Use os módulos em múltiplos projetos  
✅ **Bem Documentado**: README detalhado para cada módulo  
✅ **Seguro**: Segue as melhores práticas de segurança AWS  
✅ **Escalável**: Configurações para dev, staging e produção  
✅ **Completo**: 8 módulos cobrindo serviços essenciais da AWS

## 🏗️ Arquitetura

```
┌─────────────────────────────────────────────────────────┐
│                        INTERNET                         │
└────────────────────┬────────────────────────────────────┘
                     │
              [Internet Gateway]
                     │
┌────────────────────┴────────────────────────────────────┐
│                         VPC                             │
│                    (10.0.0.0/16)                        │
│                                                         │
│  ┌──────────────┐              ┌──────────────┐         │
│  │ Public Subnet│              │ Public Subnet│         │
│  │  10.0.1.0/24 │              │  10.0.2.0/24 │         │
│  │              │              │              │         │
│  │    [EC2]     │              │  [NAT GW]    │         │
│  │              │              │              │         │
│  └──────────────┘              └──────┬───────┘         │
│                                       │                 │
│  ┌──────────────┐              ┌──────┴───────┐         │
│  │Private Subnet│              │Private Subnet│         │
│  │ 10.0.10.0/24 │              │ 10.0.20.0/24 │         │
│  │              │              │              │         │
│  │  [Lambda]    │              │    [RDS]     │         │
│  │              │              │              │         │
│  └──────────────┘              └──────────────┘         │
│                                                         │
└─────────────────────────────────────────────────────────┘

     [S3]          [DynamoDB]         [EBS]
   Storage          NoSQL DB       Block Storage
```

## 📦 Módulos Disponíveis

| Módulo | Descrição | Status |
|--------|-----------|--------|
| **[VPC](modules/vpc/README.md)** | Rede virtual com subnets públicas/privadas |
| **[IAM](modules/iam/README.md)** | Roles e policies para serviços AWS |
| **[EC2](modules/ec2/README.md)** | Instâncias computacionais |
| **[Lambda](modules/lambda/README.md)** | Funções serverless |
| **[S3](modules/s3/README.md)** | Storage de objetos |
| **[EBS](modules/ebs/README.md)** | Volumes de block storage |
| **[RDS](modules/rds/README.md)** | Banco de dados relacional |
| **[DynamoDB](modules/dynamodb/README.md)** | Banco de dados NoSQL |

## 🔧 Pré-requisitos

### Ferramentas Necessárias

- **Terraform** >= 1.0
- **AWS CLI** >= 2.0
- **Credenciais AWS** configuradas

### Instalação

## Instalação via macOS
```bash
# Terraform
brew install terraform  # macOS
# ou
wget https://releases.hashicorp.com/terraform/1.6.0/terraform_1.6.0_linux_amd64.zip

# AWS CLI
brew install awscli  # macOS
# ou
pip install awscli

# Configurar credenciais AWS
aws configure
```

## Instalação via Linux (Debian/Ubuntu)
```bash
# Adiciona a chave GPG da HashiCorp
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg

# Adiciona o repositório oficial da HashiCorp
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list

# Atualiza e instala o Terraform
sudo apt update && sudo apt install terraform
```

## Instalação via Windows (via Chocolatey)
```bash
# Instala o Chocolatey (se ainda não tiver)
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Instala o Terraform
choco install terraform
```

### Permissões IAM Necessárias

O usuário/role AWS precisa ter permissões para criar:
- VPC, Subnets, Route Tables, Internet Gateway, NAT Gateway
- IAM Roles e Policies
- EC2 Instances, Security Groups, EBS Volumes
- Lambda Functions
- S3 Buckets
- RDS Instances
- DynamoDB Tables

## 🚀 Início Rápido

### 1. Clone o Repositório

```bash
git clone https://gitlab.com/mv-corp/govops/terraform/provider/aws
cd terraform/provider/aws
```

### 2. Configure as Variáveis

Crie um arquivo `terraform.tfvars`:

```hcl
# Global
project_name = "meu-projeto"
environment  = "dev"
aws_region   = "us-east-1"

# VPC
vpc_cidr             = "10.0.0.0/16"
availability_zones   = ["us-east-1a", "us-east-1b"]
public_subnet_cidrs  = ["10.0.1.0/24", "10.0.2.0/24"]
private_subnet_cidrs = ["10.0.10.0/24", "10.0.20.0/24"]

# EC2
ec2_ami_id        = "ami-0c55b159cbfafe1f0"
ec2_instance_type = "t3.micro"
ec2_key_name      = "minha-chave"

# Lambda
lambda_function_name    = "minha-funcao"
lambda_source_code_path = "./lambda_function.zip"

# S3
s3_bucket_name = "meu-bucket-unico-12345"

# RDS
rds_db_name  = "mydb"
rds_username = "admin"
rds_password = "SenhaSegura123!"  # Use AWS Secrets Manager em produção!

# DynamoDB
dynamodb_table_name = "minha-tabela"
```

### 3. Inicialize o Terraform

```bash
terraform init
```

### 4. Revise o Plano

```bash
terraform plan
```

### 5. Aplique a Infraestrutura

```bash
terraform apply
```

### 6. Acesse os Outputs

```bash
terraform output
```

## 📁 Estrutura do Projeto

```
.
├── README.md                 # Este arquivo
├── main.tf                   # Configuração principal
├── variables.tf              # Definição de variáveis
├── outputs.tf                # Outputs da infraestrutura
├── terraform.tfvars          # Valores das variáveis (não commitar!)
├── .gitignore
│
└── modules/
    ├── vpc/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── iam/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── ec2/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── lambda/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── s3/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── ebs/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    ├── rds/
    │   ├── main.tf
    │   ├── variables.tf
    │   ├── outputs.tf
    │   └── README.md
    │
    └── dynamodb/
        ├── main.tf
        ├── variables.tf
        ├── outputs.tf
        └── README.md
```

## 💻 Uso

### Usando Módulos Individuais

Você pode usar apenas os módulos necessários:

```hcl
# Apenas VPC e EC2
module "vpc" {
  source = "./modules/vpc"
  # ... configurações
}

module "ec2" {
  source = "./modules/ec2"
  # ... configurações
}
```

### Múltiplos Ambientes

Crie arquivos `.tfvars` para cada ambiente:

```bash
# Desenvolvimento
terraform apply -var-file="dev.tfvars"

# Produção
terraform apply -var-file="prod.tfvars"
```

### Remote State (Recomendado)

Configure backend remoto no `main.tf`:

```hcl
terraform {
  backend "s3" {
    bucket         = "meu-terraform-state"
    key            = "prod/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
```

## 📚 Exemplos

### Exemplo 1: Infraestrutura Mínima (Dev)

```hcl
# dev.tfvars
project_name = "meu-app"
environment  = "dev"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a"]

ec2_instance_type = "t3.micro"
ec2_ami_id        = "ami-0c55b159cbfafe1f0"

rds_instance_class = "db.t3.micro"
rds_multi_az       = false
```

**Custo estimado**: ~$30-50/mês

### Exemplo 2: Infraestrutura de Produção

```hcl
# prod.tfvars
project_name = "meu-app"
environment  = "prod"

vpc_cidr           = "10.0.0.0/16"
availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

ec2_instance_type = "t3.large"
ec2_ami_id        = "ami-0c55b159cbfafe1f0"

rds_instance_class          = "db.r6g.large"
rds_multi_az                = true
rds_backup_retention_period = 30

dynamodb_billing_mode = "PROVISIONED"
```

**Custo estimado**: ~$500-1000/mês

### Exemplo 3: Apenas Serverless

```hcl
# Remova módulos EC2 e RDS do main.tf
# Use apenas Lambda, S3 e DynamoDB
```

**Custo estimado**: ~$5-20/mês (pay-per-use)

## 🔧 Variáveis

### Variáveis Globais

| Nome | Tipo | Padrão | Descrição |
|------|------|--------|-----------|
| `project_name` | string | - | Nome do projeto (obrigatório) |
| `environment` | string | `"dev"` | Ambiente (dev/staging/prod) |
| `aws_region` | string | `"us-east-1"` | Região AWS |

### Variáveis por Módulo

Consulte o README de cada módulo para variáveis específicas:

- [VPC Variables](modules/vpc/README.md#variáveis-principais)
- [IAM Variables](modules/iam/README.md#variáveis-principais)
- [EC2 Variables](modules/ec2/README.md#variáveis-principais)
- [Lambda Variables](modules/lambda/README.md#variáveis-principais)
- [S3 Variables](modules/s3/README.md#variáveis-principais)
- [EBS Variables](modules/ebs/README.md#variáveis-principais)
- [RDS Variables](modules/rds/README.md#variáveis-principais)
- [DynamoDB Variables](modules/dynamodb/README.md#variáveis-principais)

## 📤 Outputs

Após `terraform apply`, você terá acesso aos seguintes outputs:

```bash
# Ver todos os outputs
terraform output

# Output específico
terraform output vpc_id
terraform output ec2_public_ip
terraform output rds_endpoint
```

### Outputs Principais

- **VPC**: `vpc_id`, `public_subnet_ids`, `private_subnet_ids`
- **EC2**: `ec2_instance_id`, `ec2_public_ip`, `ec2_private_ip`
- **Lambda**: `lambda_function_arn`, `lambda_function_name`
- **S3**: `s3_bucket_name`, `s3_bucket_arn`
- **RDS**: `rds_endpoint`, `rds_address`, `rds_port`
- **DynamoDB**: `dynamodb_table_name`, `dynamodb_table_arn`

### Output de Resumo

```bash
terraform output infrastructure_summary
```

Retorna um JSON com resumo completo da infraestrutura.

## 💰 Custos Estimados

### Ambiente de Desenvolvimento

| Serviço | Configuração | Custo/Mês |
|---------|--------------|-----------|
| VPC | Subnets + NAT Gateway | $32 |
| EC2 | t3.micro | $7 |
| Lambda | 1M invocações | $0.20 |
| S3 | 10 GB | $0.23 |
| EBS | 20 GB gp3 | $1.60 |
| RDS | db.t3.micro | $15 |
| DynamoDB | On-Demand | $1-5 |
| **Total** | | **~$57/mês** |

### Ambiente de Produção

| Serviço | Configuração | Custo/Mês |
|---------|--------------|-----------|
| VPC | Multi-AZ NAT Gateways | $64 |
| EC2 | t3.large | $61 |
| Lambda | 10M invocações | $2 |
| S3 | 100 GB | $2.30 |
| EBS | 100 GB gp3 | $8 |
| RDS | db.r6g.large Multi-AZ | $340 |
| DynamoDB | Provisioned | $20-50 |
| **Total** | | **~$500/mês** |

> ⚠️ **Nota**: Custos são estimativas. Use [AWS Calculator](https://calculator.aws/) para estimativas precisas.

## ✅ Boas Práticas

### 1. Segurança

- ✅ Nunca commite `terraform.tfvars` com credenciais
- ✅ Use AWS Secrets Manager para senhas
- ✅ Habilite criptografia em todos os recursos
- ✅ Use IAM roles ao invés de access keys
- ✅ Implemente least privilege em security groups

### 2. State Management

- ✅ Use remote state (S3 + DynamoDB)
- ✅ Habilite versioning no bucket de state
- ✅ Habilite criptografia no bucket de state
- ✅ Use state locking com DynamoDB

### 3. Organização

- ✅ Um módulo por serviço AWS
- ✅ Use workspaces para múltiplos ambientes
- ✅ Mantenha READMEs atualizados
- ✅ Use tags consistentes

### 4. Git

Adicione ao `.gitignore`:

```gitignore
# Terraform
.terraform/
*.tfstate
*.tfstate.*
*.tfvars
crash.log
override.tf
override.tf.json

# Sensitive
*.pem
*.key
secrets/
```

### 5. Custos

- ✅ Use tags para cost allocation
- ✅ Configure AWS Budgets
- ✅ Destrua recursos de dev quando não usar
- ✅ Use Reserved Instances em produção

## 🐛 Troubleshooting

### Erro: "Error creating VPC"

```bash
# Verificar limites da conta
aws service-quotas list-service-quotas \
  --service-code vpc \
  --region us-east-1
```

### Erro: "bucket already exists"

Bucket S3 deve ser globalmente único. Mude o nome em `terraform.tfvars`.

### Erro: "InvalidAMIID.NotFound"

AMI IDs são específicos por região. Verifique o AMI ID correto:

```bash
# Amazon Linux 2
aws ec2 describe-images \
  --owners amazon \
  --filters "Name=name,Values=amzn2-ami-hvm-*-x86_64-gp2" \
  --query 'sort_by(Images, &CreationDate)[-1].ImageId' \
  --output text
```

### Erro: "Invalid DB parameter"

Verifique compatibilidade de parameter group com versão da engine.

### Lambda não acessa RDS

Verifique:
1. Lambda está nas mesmas subnets privadas
2. Security group do RDS permite tráfego do Lambda
3. Lambda tem ENI criado (pode levar alguns minutos)

### Terraform Destroy Travado

```bash
# Forçar unlock do state (USE COM CUIDADO!)
terraform force-unlock <LOCK_ID>
```

## 📝 Comandos Úteis

```bash
# Validar configuração
terraform validate

# Formatar código
terraform fmt -recursive

# Ver state
terraform show

# Listar recursos
terraform state list

# Importar recurso existente
terraform import module.vpc.aws_vpc.main vpc-12345

# Destruir recurso específico
terraform destroy -target=module.ec2

# Ver grafo de dependências
terraform graph | dot -Tpng > graph.png
```

## 🔄 Workflow Recomendado

```bash
# 1. Criar branch
git checkout -b feature/nova-feature

# 2. Fazer mudanças
vim main.tf

# 3. Validar
terraform fmt
terraform validate

# 4. Testar
terraform plan

# 5. Aplicar
terraform apply

# 6. Commit
git add .
git commit -m "feat: adiciona configuração X"
git push

# 7. Pull Request
# Revisar com o time

# 8. Merge e deploy produção
```

## 🤝 Contribuindo

Contribuições são bem-vindas! Por favor:

1. Fork o projeto
2. Crie uma branch (`git checkout -b feature/AmazingFeature`)
3. Commit suas mudanças (`git commit -m 'feat: Add AmazingFeature'`)
4. Push para a branch (`git push origin feature/AmazingFeature`)
5. Abra um Pull Request

### Guidelines

- Siga as convenções do Terraform
- Atualize a documentação
- Adicione exemplos de uso
- Teste em múltiplos ambientes

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

## 🙏 Agradecimentos

- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- Comunidade Terraform

## 📞 Suporte

- 📧 Email: seu-email@example.com
- 💬 Issues: [GitHub Issues](https://github.com/seu-usuario/terraform-aws-infrastructure/issues)
- 📖 Docs: [Wiki](https://github.com/seu-usuario/terraform-aws-infrastructure/wiki)

## 🗺️ Roadmap

- [ ] Módulo ECS/Fargate
- [ ] Módulo EKS
- [ ] Módulo CloudFront + ACM
- [ ] Módulo Route53
- [ ] Módulo SQS + SNS
- [ ] Testes automatizados com Terratest
- [ ] CI/CD com GitHub Actions
- [ ] Exemplos de arquiteturas completas

---

**Construído com ❤️ usando Terraform e AWS**
