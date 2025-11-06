output "instance_id" {
  description = "ID da instância RDS"
  value       = aws_db_instance.main.id
}

output "instance_arn" {
  description = "ARN da instância RDS"
  value       = aws_db_instance.main.arn
}

output "endpoint" {
  description = "Endpoint de conexão (hostname:port)"
  value       = aws_db_instance.main.endpoint
}

output "address" {
  description = "Hostname do RDS"
  value       = aws_db_instance.main.address
}

output "port" {
  description = "Porta do RDS"
  value       = aws_db_instance.main.port
}

output "database_name" {
  description = "Nome do database"
  value       = aws_db_instance.main.db_name
}

output "username" {
  description = "Username master"
  value       = aws_db_instance.main.username
  sensitive   = true
}

output "engine" {
  description = "Engine do banco"
  value       = aws_db_instance.main.engine
}

output "engine_version" {
  description = "Versão da engine"
  value       = aws_db_instance.main.engine_version
}

output "instance_class" {
  description = "Classe da instância"
  value       = aws_db_instance.main.instance_class
}

output "allocated_storage" {
  description = "Storage alocado em GB"
  value       = aws_db_instance.main.allocated_storage
}

output "storage_type" {
  description = "Tipo de storage"
  value       = aws_db_instance.main.storage_type
}

output "storage_encrypted" {
  description = "Se storage está criptografado"
  value       = aws_db_instance.main.storage_encrypted
}

output "multi_az" {
  description = "Se Multi-AZ está habilitado"
  value       = aws_db_instance.main.multi_az
}

output "availability_zone" {
  description = "Availability zone"
  value       = aws_db_instance.main.availability_zone
}

output "backup_retention_period" {
  description = "Período de retenção de backup"
  value       = aws_db_instance.main.backup_retention_period
}

output "db_subnet_group_name" {
  description = "Nome do DB subnet group"
  value       = aws_db_subnet_group.main.name
}

output "db_subnet_group_arn" {
  description = "ARN do DB subnet group"
  value       = aws_db_subnet_group.main.arn
}

output "parameter_group_name" {
  description = "Nome do parameter group"
  value       = aws_db_instance.main.parameter_group_name
}

output "option_group_name" {
  description = "Nome do option group"
  value       = aws_db_instance.main.option_group_name
}

output "resource_id" {
  description = "Resource ID do RDS"
  value       = aws_db_instance.main.resource_id
}

output "status" {
  description = "Status da instância"
  value       = aws_db_instance.main.status
}

output "cpu_alarm_arn" {
  description = "ARN do alarme de CPU"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : null
}

output "storage_alarm_arn" {
  description = "ARN do alarme de storage"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.storage_low[0].arn : null
}

output "connection_alarm_arn" {
  description = "ARN do alarme de conexões"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.connection_count_high[0].arn : null
}

# Connection String para facilitar uso
output "connection_string" {
  description = "String de conexão completa"
  value       = "jdbc:${var.engine}://${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
}
