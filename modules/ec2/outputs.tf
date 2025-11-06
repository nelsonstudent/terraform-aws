output "instance_id" {
  description = "ID da instância EC2"
  value       = aws_instance.main.id
}

output "instance_arn" {
  description = "ARN da instância EC2"
  value       = aws_instance.main.arn
}

output "instance_state" {
  description = "Estado da instância EC2"
  value       = aws_instance.main.instance_state
}

output "public_ip" {
  description = "IP público da instância"
  value       = aws_instance.main.public_ip
}

output "private_ip" {
  description = "IP privado da instância"
  value       = aws_instance.main.private_ip
}

output "public_dns" {
  description = "DNS público da instância"
  value       = aws_instance.main.public_dns
}

output "private_dns" {
  description = "DNS privado da instância"
  value       = aws_instance.main.private_dns
}

output "elastic_ip" {
  description = "Elastic IP associado (se habilitado)"
  value       = var.associate_elastic_ip ? aws_eip.main[0].public_ip : null
}

output "elastic_ip_allocation_id" {
  description = "Allocation ID do Elastic IP"
  value       = var.associate_elastic_ip ? aws_eip.main[0].id : null
}

output "availability_zone" {
  description = "Availability zone da instância"
  value       = aws_instance.main.availability_zone
}

output "subnet_id" {
  description = "ID da subnet onde a instância está"
  value       = aws_instance.main.subnet_id
}

output "vpc_security_group_ids" {
  description = "IDs dos security groups associados"
  value       = aws_instance.main.vpc_security_group_ids
}

output "iam_instance_profile" {
  description = "IAM instance profile associado"
  value       = aws_instance.main.iam_instance_profile
}

output "key_name" {
  description = "Key pair associado"
  value       = aws_instance.main.key_name
}

output "root_block_device_volume_id" {
  description = "ID do volume root"
  value       = aws_instance.main.root_block_device[0].volume_id
}

output "cpu_alarm_arn" {
  description = "ARN do alarme de CPU"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.cpu_high[0].arn : null
}

output "status_check_alarm_arn" {
  description = "ARN do alarme de status check"
  value       = var.enable_cloudwatch_alarms ? aws_cloudwatch_metric_alarm.status_check_failed[0].arn : null
}
