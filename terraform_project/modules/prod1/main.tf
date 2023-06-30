provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "ec2" {
    ami = "ami-0261755bbcb8c4a84"
    instance_type = "t2.small"
    tags = {
        Name = "TF-Prod1-Test"
    }
}