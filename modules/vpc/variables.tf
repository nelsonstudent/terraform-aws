variable "vpc_cidr" {
  description = "CIDR block para a VPC"
  type        = string
}

variable "public_subnet_cidrs" {
  description = "Lista de CIDR blocks para subnets públicas"
  type        = list(string)
}

variable "private_subnet_cidrs" {
  description = "Lista de CIDR blocks para subnets privadas"
  type        = list(string)
}

variable "availability_zones" {
  description = "Lista de availability zones"
  type        = list(string)
}

variable "project_name" {
  description = "Nome do projeto"
  type        = string
}

variable "environment" {
  description = "Ambiente (dev, staging, prod)"
  type        = string
}

variable "enable_dns_hostnames" {
  description = "Habilitar DNS hostnames na VPC"
  type        = bool
  default     = true
}

variable "enable_dns_support" {
  description = "Habilitar DNS support na VPC"
  type        = bool
  default     = true
}

variable "enable_nat_gateway" {
  description = "Habilitar NAT Gateway para subnets privadas"
  type        = bool
  default     = true
}

variable "enable_flow_logs" {
  description = "Habilitar VPC Flow Logs"
  type        = bool
  default     = false
}

variable "flow_logs_traffic_type" {
  description = "Tipo de tráfego para Flow Logs (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
}

variable "flow_logs_retention_days" {
  description = "Dias de retenção dos Flow Logs"
  type        = number
  default     = 7
}

variable "enable_s3_endpoint" {
  description = "Habilitar VPC Endpoint para S3"
  type        = bool
  default     = false
}

variable "additional_tags" {
  description = "Tags adicionais para aplicar aos recursos"
  type        = map(string)
  default     = {}
}
