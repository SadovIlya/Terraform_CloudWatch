provider "aws" {
  region = "us-west-2"
}
resource "aws_key_pair" "deployer" {
  key_name   = "Keys1"
  public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_instance" "lab9-cloudwatch-sadov" {
  ami                  = "ami-0b9f27b05e1de14e9"
  instance_type        = "t2.micro"
  iam_instance_profile = "jenkins"
  key_name                    = "Keys1"
  vpc_security_group_ids      = ["sg-054be254844416071"]
  subnet_id                   = "subnet-0509a78580aecd2f7"
  associate_public_ip_address = "true"
  monitoring                  = "true"
  tags = {
    Name = "lab9-cloudwatch-sadov"
  }
  user_data = <<EOF
          #!/bin/bash -xe
            echo 'Amazon Linux AMI' > /etc/issue
            yum install -y gcc
            curl https://s3.amazonaws.com//aws-cloudwatch/downloads/latest/awslogs-agent-setup.py -O
            chmod +x ./awslogs-agent-setup.py
            ./awslogs-agent-setup.py -n -r us-west-2 -c https://raw.githubusercontent.com/cloudacademy/labs-CloudWatch-SSHfailures/master/LogAgentConfig.txt
            /opt/aws/bin/cfn-signal -e 0 --stack cloudacademylabs --resource MonitorCloudWatchLabInstance  --region us-west-2
	EOF
}

resource "aws_sns_topic" "sadov-SSH_Fails" {
  name = "sadov-SSH_Fails"
}

resource "aws_sns_topic_subscription" "sadov-SSH_Fails" {
  topic_arn = "${aws_sns_topic.sadov-SSH_Fails.arn}"
  protocol  = "email"
  endpoint  = "sadov94@yandex.ru"
}

resource "aws_cloudwatch_metric_alarm" "lab9-sadov-alarm" {
  alarm_name          = "lab9-sadov-alarm"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 1
  metric_name         = "IncomingLogEvents"
  namespace           = "AWS/Logs"
  period              = 60
  statistic           = "Sum"
  threshold           = 2
  alarm_description   = "IncomingLogEvents"
  alarm_actions       = ["${aws_sns_topic.sadov-SSH_Fails.arn}"]
  
}

resource "aws_cloudwatch_log_metric_filter" "sadov-lab9-filter-metrics" {
  name           = "sadov-lab5-filter-metrics"
  pattern        = "[Mon, day, timestamp, ip, id, status = Invalid, ...]"
  log_group_name = "SSHfail"

  metric_transformation {
    name      = "sadov-lab9-filter-metrics"
    namespace = "sadov-lab9-filter-metrics"
    value     = "2"
  }
}