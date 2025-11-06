resource "aws_instance" "main" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.vpc_security_group_ids
  iam_instance_profile   = var.iam_instance_profile
  key_name               = var.key_name

  # Root Volume Configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = var.root_volume_encrypted
    delete_on_termination = var.root_volume_delete_on_termination
    
    tags = {
      Name        = "${var.project_name}-${var.environment}-root-volume"
      Project     = var.project_name
      Environment = var.environment
    }
  }

  # Additional EBS Volumes
  dynamic "ebs_block_device" {
    for_each = var.ebs_block_devices
    content {
      device_name           = ebs_block_device.value.device_name
      volume_type           = lookup(ebs_block_device.value, "volume_type", "gp3")
      volume_size           = ebs_block_device.value.volume_size
      iops                  = lookup(ebs_block_device.value, "iops", null)
      throughput            = lookup(ebs_block_device.value, "throughput", null)
      encrypted             = lookup(ebs_block_device.value, "encrypted", true)
      delete_on_termination = lookup(ebs_block_device.value, "delete_on_termination", true)
    }
  }

  # User Data
  user_data                   = var.user_data
  user_data_replace_on_change = var.user_data_replace_on_change

  # Monitoring
  monitoring = var.enable_detailed_monitoring

  # Metadata Options (IMDSv2)
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = var.require_imdsv2 ? "required" : "optional"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Credit Specification for T-family instances
  dynamic "credit_specification" {
    for_each = length(regexall("^t[2-4]", var.instance_type)) > 0 ? [1] : []
    content {
      cpu_credits = var.cpu_credits
    }
  }

  # Disable API termination for production
  disable_api_termination = var.disable_api_termination

  # EBS Optimized
  ebs_optimized = var.ebs_optimized

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-instance"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )

  volume_tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-volume"
      Project     = var.project_name
      Environment = var.environment
    },
    var.additional_tags
  )

  lifecycle {
    ignore_changes = [
      ami,
      user_data,
    ]
  }
}

# Elastic IP (opcional)
resource "aws_eip" "main" {
  count = var.associate_elastic_ip ? 1 : 0

  instance = aws_instance.main.id
  domain   = "vpc"

  tags = {
    Name        = "${var.project_name}-${var.environment}-eip"
    Project     = var.project_name
    Environment = var.environment
  }

  depends_on = [aws_instance.main]
}

# CloudWatch Alarms (opcional)
resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "300"
  statistic           = "Average"
  threshold           = var.cpu_alarm_threshold
  alarm_description   = "Alarme quando CPU excede ${var.cpu_alarm_threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-cpu-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "status_check_failed" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-status-check-failed"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "StatusCheckFailed"
  namespace           = "AWS/EC2"
  period              = "60"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "Alarme quando status check falha"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-status-check-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}
