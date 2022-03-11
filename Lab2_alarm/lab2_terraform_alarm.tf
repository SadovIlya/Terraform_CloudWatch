provider "aws" {
  region = "us-west-2"
}


resource "aws_cloudwatch_metric_alarm" "sadov-my_alarm" {
  alarm_name          = "sadov-2-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "Stop the EC2 instance when CPU utilization stays below 10% on average for 12 periods of 5 minutes, i.e. 1 hour"
  alarm_actions       = ["${aws_sns_topic.user_updates.arn}", "arn:aws:automate:us-west-2:ec2:reboot"]
  dimensions = {
    InstanceId = "i-08c17c8960d899a21"
  }
}
 
resource "aws_sns_topic" "user_updates" {
  name = "sadov-updates-topic"
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
  topic_arn = "${aws_sns_topic.user_updates.arn}"
  protocol  = "email"
  endpoint  = "sadov94@yandex.ru"
}