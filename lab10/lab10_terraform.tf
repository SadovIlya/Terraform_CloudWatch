provider "aws" {
  region = "us-west-2"
}

resource "aws_cloudtrail" "lab10-sadov-trail" {
  name                          = "lab10-sadov-trail"
  s3_bucket_name                = "${aws_s3_bucket.lab10-sadov-trail-bucket.id}"
  s3_key_prefix                 = "prefix"  
  cloud_watch_logs_group_arn    = "${aws_cloudwatch_log_group.cloudtrail-group-sadov.arn}:*"
  cloud_watch_logs_role_arn     = "${aws_iam_role.sadov-role-cloudtrail.arn}"
}

resource "aws_iam_policy" "sadov-policy-trail" {
  name        = "sadov-policy-trail"
  path        = "/"
  description = "sadov-policy-trail"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailCreateLogStream2014110",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream"
            ],
            "Resource": [
                "arn:aws:logs:us-west-2:529396670287:log-group:cloudtrail-group-sadov:log-stream:529396670287_CloudTrail_us-west-2*"
            ]
        },
        {
            "Sid": "AWSCloudTrailPutLogEvents20141101",
            "Effect": "Allow",
            "Action": [
                "logs:PutLogEvents"
            ],
            "Resource": [
                "arn:aws:logs:us-west-2:529396670287:log-group:cloudtrail-group-sadov:log-stream:529396670287_CloudTrail_us-west-2*"
            ]
        }
    ]
}
EOF
}

resource "aws_iam_policy_attachment" "test-attach" {
  name       = "test-attachment"
  roles      = ["${aws_iam_role.sadov-role-cloudtrail.name}"]
  policy_arn = "${aws_iam_policy.sadov-policy-trail.arn}"
}



resource "aws_iam_role" "sadov-role-cloudtrail" {
  name = "sadov-role-cloudtrail"
 
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "sts:AssumeRole"
            ],
            "Effect": "Allow",
            "Principal": {
                "Service": [
                    "cloudtrail.amazonaws.com"
                ]
            }
        }
    ]
}
EOF  
}

resource "aws_cloudwatch_log_group" "cloudtrail-group-sadov" {
  name = "cloudtrail-group-sadov"
  retention_in_days = 1 
}

resource "aws_s3_bucket" "lab10-sadov-trail-bucket" {
  bucket        = "lab10-sadov-trail-bucket"
  force_destroy = true   
}

resource "aws_s3_bucket_policy" "lab10-sadov-trail-bucket-policy" {
  bucket = "${aws_s3_bucket.lab10-sadov-trail-bucket.id}"
  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "AWSCloudTrailAclCheck",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:GetBucketAcl",
            "Resource": "arn:aws:s3:::lab10-sadov-trail-bucket"
        },
        {
            "Sid": "AWSCloudTrailWrite",
            "Effect": "Allow",
            "Principal": {
              "Service": "cloudtrail.amazonaws.com"
            },
            "Action": "s3:PutObject",
            "Resource": "arn:aws:s3:::lab10-sadov-trail-bucket/*",
            "Condition": {
                "StringEquals": {
                    "s3:x-amz-acl": "bucket-owner-full-control"
                }
            }
        }
    ]
}
POLICY
}

resource "aws_cloudwatch_log_metric_filter" "sadov-lab10-filter-metrics" {
  name           = "sadov-lab10-filter-metrics"
  pattern        = "{$.sourceIPAddress=\"188.16.84.134\"}"
  log_group_name = "cloudtrail-group-sadov"

  metric_transformation {
    name      = "sadov-lab10-filter-metrics"
    namespace = "sadov-lab10-filter-metrics"
    value     = "10"
  }
}

resource "aws_cloudwatch_log_metric_filter" "sadov-lab10-filter-metrics-2" {
  name           = "sadov-lab10-filter-metrics-2"
  pattern        = "{ ( $.eventName = StopInstances ) || ( $.eventName = TerminateInstances ) || ( $.eventName = RunInstances ) }"
  log_group_name = "cloudtrail-group-sadov"

  metric_transformation {
    name      = "sadov-lab10-filter-metrics-2"
    namespace = "sadov-lab10-filter-metrics-2"
    value     = "1"
  }
}

resource "aws_sns_topic" "sadov-ip-lab10" {
  name = "sadov-ip-lab10"
}

resource "aws_sns_topic_subscription" "sadov-ip-lab10-sub" {
  topic_arn = "${aws_sns_topic.sadov-ip-lab10.arn}"
  protocol  = "email"
  endpoint  = "sadov94@yandex.ru"
}

resource "aws_cloudwatch_metric_alarm" "lab10-sadov-alarm" {
  alarm_name          = "lab10-sadov-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "sadov-lab10-filter-metrics"
  namespace           = "sadov-lab10-filter-metrics"
  period              = 60
  statistic           = "Sum"
  threshold           = 10
  alarm_description   = "IncomingLogEvents"
  alarm_actions       = ["${aws_sns_topic.sadov-ip-lab10.arn}"]
  
}

resource "aws_cloudwatch_metric_alarm" "lab10-sadov-alarm-2" {
  alarm_name          = "lab10-sadov-alarm-2"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "sadov-lab10-filter-metrics-2"
  namespace           = "sadov-lab10-filter-metrics-2"
  period              = 60
  statistic           = "Sum"
  threshold           = 1
  alarm_description   = "IncomingLogEvents"
  alarm_actions       = ["${aws_sns_topic.sadov-ip-lab10.arn}"]
  
}