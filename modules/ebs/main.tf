# ==========================================
# modules/ebs/main.tf
# ==========================================

# EBS Volume
resource "aws_ebs_volume" "main" {
  availability_zone    = var.availability_zone
  size                 = var.size
  type                 = var.volume_type
  iops                 = var.iops
  throughput           = var.throughput
  encrypted            = var.encrypted
  kms_key_id           = var.kms_key_id
  snapshot_id          = var.snapshot_id
  multi_attach_enabled = var.multi_attach_enabled

  tags = merge(
    {
      Name        = "${var.project_name}-${var.environment}-ebs-volume"
      Project     = var.project_name
      Environment = var.environment
      ManagedBy   = "Terraform"
    },
    var.additional_tags
  )
}

# Volume Attachment (opcional)
resource "aws_volume_attachment" "main" {
  count = var.instance_id != null ? 1 : 0

  device_name  = var.device_name
  volume_id    = aws_ebs_volume.main.id
  instance_id  = var.instance_id
  force_detach = var.force_detach
  skip_destroy = var.skip_destroy
}

# Snapshot Schedule usando DLM (Data Lifecycle Manager)
resource "aws_dlm_lifecycle_policy" "ebs_snapshot" {
  count = var.enable_snapshot_lifecycle ? 1 : 0

  description        = "EBS snapshot policy for ${var.project_name}-${var.environment}"
  execution_role_arn = var.dlm_role_arn
  state              = var.snapshot_lifecycle_state

  policy_details {
    resource_types = ["VOLUME"]

    schedule {
      name = "Daily snapshots for ${var.project_name}-${var.environment}"

      create_rule {
        interval      = var.snapshot_interval
        interval_unit = var.snapshot_interval_unit
        times         = var.snapshot_times
      }

      retain_rule {
        count = var.snapshot_retention_count
      }

      tags_to_add = {
        SnapshotType = "DLM"
        Project      = var.project_name
        Environment  = var.environment
        CreatedBy    = "Terraform-DLM"
      }

      copy_tags = true
    }

    target_tags = {
      Name = "${var.project_name}-${var.environment}-ebs-volume"
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-snapshot-policy"
    Project     = var.project_name
    Environment = var.environment
  }
}

# IAM Role para DLM (se habilitado e role não fornecida)
resource "aws_iam_role" "dlm" {
  count = var.enable_snapshot_lifecycle && var.dlm_role_arn == null ? 1 : 0

  name_prefix = "${var.project_name}-${var.environment}-dlm-"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "dlm.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-${var.environment}-dlm-role"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_iam_role_policy" "dlm" {
  count = var.enable_snapshot_lifecycle && var.dlm_role_arn == null ? 1 : 0

  name_prefix = "dlm-policy-"
  role        = aws_iam_role.dlm[0].id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateSnapshot",
          "ec2:CreateSnapshots",
          "ec2:DeleteSnapshot",
          "ec2:DescribeVolumes",
          "ec2:DescribeSnapshots",
          "ec2:DescribeInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ec2:CreateTags"
        ]
        Resource = "arn:aws:ec2:*::snapshot/*"
      }
    ]
  })
}

# CloudWatch Alarms
resource "aws_cloudwatch_metric_alarm" "volume_idle" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ebs-volume-idle"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "24"
  metric_name         = "VolumeIdleTime"
  namespace           = "AWS/EBS"
  period              = "3600"
  statistic           = "Average"
  threshold           = var.idle_time_threshold
  alarm_description   = "Alarme quando volume está ocioso por muito tempo"
  treat_missing_data  = "notBreaching"

  dimensions = {
    VolumeId = aws_ebs_volume.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-idle-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "burst_balance_low" {
  count = var.enable_cloudwatch_alarms && contains(["gp2", "st1", "sc1"], var.volume_type) ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ebs-burst-balance-low"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "BurstBalance"
  namespace           = "AWS/EBS"
  period              = "300"
  statistic           = "Average"
  threshold           = var.burst_balance_threshold
  alarm_description   = "Alarme quando burst balance está abaixo de ${var.burst_balance_threshold}%"
  treat_missing_data  = "notBreaching"

  dimensions = {
    VolumeId = aws_ebs_volume.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-burst-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "volume_read_ops_high" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ebs-read-ops-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "VolumeReadOps"
  namespace           = "AWS/EBS"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.read_ops_threshold
  alarm_description   = "Alarme quando operações de leitura excedem ${var.read_ops_threshold}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    VolumeId = aws_ebs_volume.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-read-ops-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

resource "aws_cloudwatch_metric_alarm" "volume_write_ops_high" {
  count = var.enable_cloudwatch_alarms ? 1 : 0

  alarm_name          = "${var.project_name}-${var.environment}-ebs-write-ops-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "VolumeWriteOps"
  namespace           = "AWS/EBS"
  period              = "300"
  statistic           = "Sum"
  threshold           = var.write_ops_threshold
  alarm_description   = "Alarme quando operações de escrita excedem ${var.write_ops_threshold}"
  treat_missing_data  = "notBreaching"

  dimensions = {
    VolumeId = aws_ebs_volume.main.id
  }

  tags = {
    Name        = "${var.project_name}-${var.environment}-ebs-write-ops-alarm"
    Project     = var.project_name
    Environment = var.environment
  }
}

# Atualizar role ARN para DLM se criada localmente
locals {
  dlm_role_arn = var.enable_snapshot_lifecycle ? (
    var.dlm_role_arn != null ? var.dlm_role_arn : aws_iam_role.dlm[0].arn
  ) : null
}
