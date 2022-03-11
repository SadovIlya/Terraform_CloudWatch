provider "aws" {
  region = "us-west-2"
}
resource "aws_key_pair" "deployer" {
  key_name   = "Keys1"
  public_key = file("~/.ssh/id_rsa.pub")
}
resource "aws_instance" "cloudwatch-lab-sadov" {
  ami                  = "ami-0b9f27b05e1de14e9"
  instance_type        = "t2.micro"
  iam_instance_profile = "jenkins"
  key_name                    = "Keys1"
  vpc_security_group_ids      = ["sg-054be254844416071"]
  subnet_id                   = "subnet-0509a78580aecd2f7"
  associate_public_ip_address = "true"
  monitoring                  = "true"
  tags = {
    Name = "cloudwatch-lab-sadov"
  }
  user_data = <<EOF
          #!/bin/bash
          yum install -y perl-Switch perl-DateTime perl-Sys-Syslog perl-LWP-Protocol-https perl-Digest-SHA.x86_64
          wget http://aws-cloudwatch.s3.amazonaws.com/downloads/CloudWatchMonitoringScripts-1.2.2.zip
          unzip CloudWatchMonitoringScripts-1.2.2.zip
          rm CloudWatchMonitoringScripts-1.2.2.zip
          echo "*/1 * * * * /aws-scripts-mon/mon-put-instance-data.pl --mem-util --disk-space-util --disk-path=/ --from-cron" > monitoring.txt
          crontab monitoring.txt
          rm monitoring.txt
	EOF
}


