provider "aws" {
  region = "us-west-2"
}

resource "aws_sns_topic" "sadov-lab5-sns" {
  name = "sadov-lab5-sns"
}

resource "aws_cloudwatch_log_metric_filter" "sadov-lab5-filter-metrics" {
  name           = "sadov-lab5-filter-metrics"
  pattern        = "{ $.QueuedMessages != \"0\" }"
  log_group_name = "${aws_cloudwatch_log_group.sadov-lab5-log-group.name}"

  metric_transformation {
    name      = "sadov-lab5"
    namespace = "sadov-lab5"
    value     = "1"
  }
}

resource "aws_cloudwatch_log_stream" "sadov-lab5-log-stream" {
  name           = "sadov-lab5-log-stream"
  log_group_name = "${aws_cloudwatch_log_group.sadov-lab5-log-group.name}"
}

resource "aws_cloudwatch_log_group" "sadov-lab5-log-group" {
  name = "sadov-lab5-log-group"
  retention_in_days = 1 
}

resource "aws_sns_topic_policy" "sadov-lab5-sns-policy" {
  arn =  "${aws_sns_topic.sadov-lab5-sns.arn}"
  policy = "${data.aws_iam_policy_document.sns-topic-policy.json}"
}

data "aws_iam_policy_document" "sns-topic-policy" {
  policy_id = "__default_policy_ID"

  statement {
    actions = [
        "SNS:Publish",
        "SNS:RemovePermission",
        "SNS:SetTopicAttributes",
        "SNS:DeleteTopic",
        "SNS:ListSubscriptionsByTopic",
        "SNS:GetTopicAttributes",
        "SNS:AddPermission",
        "SNS:Subscribe"
    ]

    condition {
      test     = "StringEquals"
      variable = "AWS:SourceOwner"

      values = [
        "529396670287",
      ]
    }

    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["*"]
    }

    resources = [
      "${aws_sns_topic.sadov-lab5-sns.arn}",
    ]

    sid = "__default_statement_ID"
  }
}

resource "aws_cloudwatch_metric_alarm" "sadov-lab5-alarm" {
  alarm_name          = "sadov-lab5-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "sadov-lab5"
  namespace           = "AWS/EC2"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "Stop the EC2 instance when CPU utilization stays below 10% on average for 12 periods of 5 minutes, i.e. 1 hour"
  alarm_actions       = ["${aws_sns_topic.sadov-lab5-sns.arn}"]
  treat_missing_data  = "notBreaching" 
}
 
