provider "aws" {
  region = "us-west-2"
}

variable "ec2-instance" {
  type = string
  default = "i-08c17c8960d899a21"
}


resource "aws_cloudwatch_dashboard" "started-dashboard" {
  dashboard_name = "sadovs-dashboard-lab2"  

  dashboard_body = <<EOF
  { 
    "widgets": [
                  {
                      "type": "metric",
                      "x": 0,
                      "y": 0,
                      "width": 12,
                      "height": 6,
                      "properties": {
                          "metrics": [
                              [ "System/Linux", "DiskSpaceUtilization", "InstanceId", "${var.ec2-instance}", "Filesystem", "/dev/xvda1", "MountPath", "/" ],
                              [ "System/Linux", "MemoryUtilization", "InstanceId", "${var.ec2-instance}"]
                          ],      
                                              
                          "region": "us-west-2",
                          "stat": "Maximum",
                          "period": 60,
                          "view": "timeSeries",
                          "title": "CPUUtilization",
                          "stacked": false
            }
        }
        ]
    }
    EOF
}