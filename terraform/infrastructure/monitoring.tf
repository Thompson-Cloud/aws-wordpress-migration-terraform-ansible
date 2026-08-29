# ------------------------------------------------------------
# SNS Topic for Infrastructure Alerts
# ------------------------------------------------------------

resource "aws_sns_topic" "wordpress_alerts" {
  name = "wordpress-migration-alerts"

  tags = {
    Name = "wordpress-migration-alerts"
  }
}

# Email subscription for CloudWatch alerts.
# AWS requires the recipient to confirm the subscription
# before notifications can be delivered.
resource "aws_sns_topic_subscription" "email_alerts" {
  topic_arn = aws_sns_topic.wordpress_alerts.arn
  protocol  = "email"
  endpoint  = var.alert_email
}


# ------------------------------------------------------------
# WordPress EC2 CPU Monitoring
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "wordpress_ec2_cpu_high" {
  alarm_name        = "wordpress-ec2-high-cpu"
  alarm_description = "Triggers when WordPress EC2 CPU utilization remains at or above 80 percent."

  namespace   = "AWS/EC2"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 2
  threshold          = 80

  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    InstanceId = aws_instance.wordpress.id
  }

  alarm_actions = [
    aws_sns_topic.wordpress_alerts.arn
  ]

  tags = {
    Name = "wordpress-ec2-high-cpu"
  }
}


# ------------------------------------------------------------
# RDS CPU Monitoring
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "wordpress_rds_cpu_high" {
  alarm_name        = "wordpress-rds-high-cpu"
  alarm_description = "Triggers when WordPress RDS CPU utilization remains at or above 80 percent."

  namespace   = "AWS/RDS"
  metric_name = "CPUUtilization"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 2
  threshold          = 80

  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.identifier
  }

  alarm_actions = [
    aws_sns_topic.wordpress_alerts.arn
  ]

  tags = {
    Name = "wordpress-rds-high-cpu"
  }
}


# ------------------------------------------------------------
# RDS Database Connection Monitoring
# ------------------------------------------------------------

resource "aws_cloudwatch_metric_alarm" "wordpress_rds_connections_high" {
  alarm_name        = "wordpress-rds-high-connections"
  alarm_description = "Triggers when WordPress RDS database connections remain at or above 50."

  namespace   = "AWS/RDS"
  metric_name = "DatabaseConnections"
  statistic   = "Average"

  period             = 300
  evaluation_periods = 2
  threshold          = 50

  comparison_operator = "GreaterThanOrEqualToThreshold"
  treat_missing_data  = "notBreaching"

  dimensions = {
    DBInstanceIdentifier = aws_db_instance.wordpress.identifier
  }

  alarm_actions = [
    aws_sns_topic.wordpress_alerts.arn
  ]

  tags = {
    Name = "wordpress-rds-high-connections"
  }
}