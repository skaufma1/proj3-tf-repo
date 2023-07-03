provider "aws" {
    region = "us-east-1"
}

data "aws_instances" "ec2_prod1_instance" {
    filter {
        name   = "tag:Name"
        values = ["proj3-tf-prod1"]
    }
}

data "aws_instances" "ec2_prod2_instance" {
    filter {
        name   = "tag:Name"
        values = ["proj3-tf-prod2"]
    }
}

resource "aws_lb_target_group" "tg" {
    name     = "my-target-group"
    port     = 80
    protocol = "HTTP"
    vpc_id   = "vpc-081229f33440b91ea"

    health_check {
        path                = "/"
        port                = 5000
        protocol            = "HTTP"
        healthy_threshold   = 2
        unhealthy_threshold = 2
        timeout             = 5
        interval            = 30
    }
}

resource "aws_lb_target_group_attachment" "attach_prod1" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = data.aws_instances.ec2_prod1_instance.ids[0]
}

resource "aws_lb_target_group_attachment" "attach_prod2" {
    target_group_arn = aws_lb_target_group.tg.arn
    target_id        = data.aws_instances.ec2_prod2_instance.ids[0]
}

resource "aws_lb_listener" "listener" {
    load_balancer_arn = aws_lb.load_balancer.arn
    port              = 80
    protocol          = "HTTP"

    default_action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }
}

resource "aws_lb" "load_balancer" {
    name             = "proj3-tf-lb"
    internal         = false
    load_balancer_type = "application"

    subnets = [
        "subnet-0fc1eecf0a8d5fe36",
        "subnet-0a01c96aef97d56bd",
        "subnet-0ca600ed19f9d5a48",
        "subnet-04db0ab5196e2f002",
        "subnet-0f30605e99b332f16",
        "subnet-07a42efc118a52b57"
    ]

    security_groups = [
        "sg-00102fd2ef88fd054",
        "sg-0be101c0f47493d2e"
    ]
}

resource "aws_lb_listener_rule" "tg_rule" {
    listener_arn = aws_lb_listener.listener.arn

    action {
        type             = "forward"
        target_group_arn = aws_lb_target_group.tg.arn
    }

    # Default condition - referring to all incoming traffic and filtering nothing
    condition {
        path_pattern {
            values = ["*"]
        }
    }
}


