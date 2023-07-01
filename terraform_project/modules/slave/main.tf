provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "ec2" {
    ami = "ami-0261755bbcb8c4a84"
    instance_type = "t2.small"
    tags = {
        Name = "TF-Slave-Test"
    }
}

# Create elastic ip
resource "aws_eip" "lb" {
    vpc = true
}

# connecting between ec2 instance and elastic ip instance
resource "aws_eip_association" "eip_assoc" {
    instance_id = aws_instance.ec2.id
    allocation_id = aws_eip.lb.id
}
