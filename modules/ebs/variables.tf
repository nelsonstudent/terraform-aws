# Required Variables
variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "availability_zone" {
  description = "Availability zone onde o volume será criado"
  type        = string
}

variable "size" {
  description = "Tamanho do volume em GB"
  type        = number

  validation {
    condition     = var.size >= 1 && var.size <= 16384
    error_message = "Volume size must be between 1 GB and 16 TB (16384 GB)."
  }
}

# Volume Configuration
variable "volume_type" {
  description = "Tipo do volume EBS (gp2, gp3, io1, io2, st1, sc1)"
  type        = string
  default     = "gp3"

  validation {
    condition     = contains(["gp2", "gp3", "io1", "io2", "st1", "sc1"], var.volume_type)
    error_message = "Volume type must be gp2, gp3, io1, io2, st1, or sc1."
  }
}

variable "iops" {
  description = "IOPS provisionados para volumes io1, io2 ou gp3 (3000-16000 para gp3, até 64000 para io1/io2)"
  type        = number
  default     = null

  validation {
    condition     = var.iops == null || (var.iops >= 100 && var.iops <= 64000)
    error_message = "IOPS must be between 100 and 64000."
  }
}

variable "throughput" {
  description = "Throughput em MB/s para volumes gp3 (125-1000)"
  type        = number
  default     = null

  validation {
    condition     = var.throughput == null || (var.throughput >= 125 && var.throughput <= 1000)
    error_message = "Throughput must be between 125 and 1000 MB/s."
  }
}

# Encryption
variable "encrypted" {
  description = "Habilitar criptografia do volume"
  type        = bool
  default     = true
}

variable "kms_key_id" {
  description = "ARN da chave KMS para criptografia (null = usar chave padrão da AWS)"
  type        = string
  default     = null
}

# Snapshot
variable "snapshot_id" {
  description = "ID do snapshot para criar o volume a partir dele"
  type        = string
  default     = null
}

# Multi-Attach (apenas io1/io2)
variable "multi_attach_enabled" {
  description = "Habilitar multi-attach (permite anexar a múltiplas instâncias - apenas io1/io2 em mesma AZ)"
  type        = bool
  default     = false
}

# Volume Attachment
variable "instance_id" {
  description = "ID da instância EC2 para anexar o volume automaticamente"
  type        = string
  default     = null
}

variable "device_name" {
  description = "Nome do device para attachment (ex: /dev/sdf, /dev/xvdf)"
  type        = string
  default     = "/dev/sdf"
}

variable "force_detach" {
  description = "Forçar detach do volume ao destruir o attachment"
  type        = bool
  default     = false
}

variable "skip_destroy" {
  description = "Não fazer detach do volume ao destruir o attachment"
  type        = bool
  default     = false
}

# Snapshot Lifecycle (DLM)
variable "enable_snapshot_lifecycle" {
  description = "Habilitar política automática de snapshots usando DLM"
  type        = bool
  default     = false
}

variable "dlm_role_arn" {
  description = "ARN da IAM role para DLM (null = criar automaticamente)"
  type        = string
  default     = null
}

variable "snapshot_lifecycle_state" {
  description = "Estado da política de lifecycle (ENABLED ou DISABLED)"
  type        = string
  default     = "ENABLED"

  validation {
    condition     = contains(["ENABLED", "DISABLED"], var.snapshot_lifecycle_state)
    error_message = "State must be ENABLED or DISABLED."
  }
}

variable "snapshot_interval" {
  description = "Intervalo entre snapshots (em horas ou dias conforme snapshot_interval_unit)"
  type        = number
  default     = 24
}

variable "snapshot_interval_unit" {
  description = "Unidade do intervalo de snapshots (HOURS ou DAYS)"
  type        = string
  default     = "HOURS"

  validation {
    condition     = contains(["HOURS", "DAYS"], var.snapshot_interval_unit)
    error_message = "Interval unit must be HOURS or DAYS."
  }
}

variable "snapshot_times" {
  description = "Horários para criar snapshots no formato HH:MM (UTC)"
  type        = list(string)
  default     = ["03:00"]

  validation {
    condition = alltrue([
      for time in var.snapshot_times : can(regex("^([0-1][0-9]|2[0-3]):[0-5][0-9]$", time))
    ])
    error_message = "Times must be in HH:MM format (00:00 to 23:59)."
  }
}

variable "snapshot_retention_count" {
  description = "Número de snapshots a reter (snapshots mais antigos são deletados automaticamente)"
  type        = number
  default     = 7

  validation {
    condition     = var.snapshot_retention_count >= 1 && var.snapshot_retention_count <= 1000
    error_message = "Retention count must be between 1 and 1000."
  }
}

# CloudWatch Alarms
variable "enable_cloudwatch_alarms" {
  description = "Habilitar alarmes do CloudWatch para monitoramento do volume"
  type        = bool
  default     = false
}

variable "idle_time_threshold" {
  description = "Threshold de idle time em segundos (alarme se volume ficar idle abaixo deste valor)"
  type        = number
  default     = 300
}

variable "burst_balance_threshold" {
  description = "Threshold de burst balance em % (alarme se cair abaixo - apenas gp2, st1, sc1)"
  type        = number
  default     = 20

  validation {
    condition     = var.burst_balance_threshold >= 0 && var.burst_balance_threshold <= 100
    error_message = "Burst balance threshold must be between 0 and 100%."
  }
}

variable "read_ops_threshold" {
  description = "Threshold de operações de leitura para alarme"
  type        = number
  default     = 10000
}

variable "write_ops_threshold" {
  description = "Threshold de operações de escrita para alarme"
  type        = number
  default     = 10000
}

# Tags
variable "additional_tags" {
  description = "Tags adicionais para aplicar ao volume e recursos relacionados"
  type        = map(string)
  default     = {}
}
