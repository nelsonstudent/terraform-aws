variable "ami_id" {
  description = "AMI ID para a instância EC2"
  type        = string
}

variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
}

variable "subnet_id" {
  description = "ID da subnet onde a instância será criada"
  type        = string
}

variable "vpc_security_group_ids" {
  description = "Lista de IDs dos security groups"
  type        = list(string)
}

variable "iam_instance_profile" {
  description = "Nome do IAM instance profile"
  type        = string
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "key_name" {
  description = "Nome do key pair para acesso SSH"
  type        = string
  default     = null
}

# Root Volume Configuration
variable "root_volume_type" {
  description = "Tipo do volume root (gp2, gp3, io1, io2)"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Tamanho do volume root em GB"
  type        = number
  default     = 20
}

variable "root_volume_encrypted" {
  description = "Habilitar criptografia no volume root"
  type        = bool
  default     = true
}

variable "root_volume_delete_on_termination" {
  description = "Deletar volume root ao terminar instância"
  type        = bool
  default     = true
}

# Additional EBS Volumes
variable "ebs_block_devices" {
  description = "Lista de volumes EBS adicionais"
  type = list(object({
    device_name           = string
    volume_size           = number
    volume_type           = optional(string)
    iops                  = optional(number)
    throughput            = optional(number)
    encrypted             = optional(bool)
    delete_on_termination = optional(bool)
  }))
  default = []
}

# User Data
variable "user_data" {
  description = "Script de user data para inicialização"
  type        = string
  default     = null
}

variable "user_data_replace_on_change" {
  description = "Recriar instância quando user data mudar"
  type        = bool
  default     = false
}

# Monitoring
variable "enable_detailed_monitoring" {
  description = "Habilitar detailed monitoring (CloudWatch a cada 1 minuto)"
  type        = bool
  default     = false
}

# IMDSv2
variable "require_imdsv2" {
  description = "Requer IMDSv2 (Instance Metadata Service v2)"
  type        = bool
  default     = true
}

# CPU Credits for T-family instances
variable "cpu_credits" {
  description = "Opção de CPU credits para instâncias T (standard ou unlimited)"
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "unlimited"], var.cpu_credits)
    error_message = "CPU credits must be standard or unlimited."
  }
}

# Protection
variable "disable_api_termination" {
  description = "Desabilitar terminação via API"
  type        = bool
  default     = false
}

# EBS Optimized
variable "ebs_optimized" {
  description = "Habilitar EBS optimized"
  type        = bool
  default     = true
}

# Elastic IP
variable "associate_elastic_ip" {
  description = "Associar Elastic IP à instância"
  type        = bool
  default     = false
}

# CloudWatch Alarms
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes do CloudWatch"
  type        = bool
  default     = false
}

variable "cpu_alarm_threshold" {
  description = "Threshold de CPU para alarme (0-100%)"
  type        = number
  default     = 80
}

# Tags
variable "additional_tags" {
  description = "Tags adicionais para aplicar aos recursos"
  type        = map(string)
  default     = {}
}
