provider "aws" {
    region = "us-east-1"
}

# Using an existing Security Group, allowing 'All' access
data "aws_security_group" "existing" {
    name = "launch-wizard-1"
}

resource "aws_instance" "ec2" {
    ami = "ami-0261755bbcb8c4a84"
    instance_type = "t2.small"
    vpc_security_group_ids = [data.aws_security_group.existing.id]
    key_name = "proj1-flask-slave"
    tags = {
        Name = "proj3-tf-slave"
    }
    
    root_block_device {
        volume_type           = "gp3"
        volume_size           = 20
        delete_on_termination = true
    }

    # Script run at EC2 instance launch - installing the node_exporter as always ON + dethaced
    user_data = <<-EOF
        #!/bin/bash
        sudo wget https://github.com/prometheus/node_exporter/releases/download/v1.3.1/node_exporter-1.3.1.linux-amd64.tar.gz
        sudo tar xvf node_exporter-1.3.1.linux-amd64.tar.gz
        cd node_exporter-1.3.1.linux-amd64
        sudo cp node_exporter /usr/local/bin

        cat <<-SERVICE_EOF > /etc/systemd/system/node_exporter.service
            [Unit]
            Description=Node Exporter
            Wants=network-online.target
            After=network-online.target

            [Service]
            ExecStart=/usr/local/bin/node_exporter  
            User=ubuntu  

            [Install]
            WantedBy=default.target
        SERVICE_EOF

        systemctl daemon-reload
        systemctl enable node_exporter.service
        systemctl start node_exporter.service
    EOF

    # Establishing connection to the new EC2 for 'remote-exec'
    connection {
        type        = "ssh"
        user        = "ubuntu"  
        private_key = file("/var/jenkins_home/proj1-flask-slave.pem")  
        host = aws_instance.ec2.public_ip
    }

    provisioner "remote-exec" {
        inline = [
            # Docker installation
            "sudo apt-get update && sudo apt-get upgrade -y",
            "sudo apt-get install -y ca-certificates curl gnupg",
            "sudo install -m 0755 -d /etc/apt/keyrings",
            "curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg",
            "sudo chmod a+r /etc/apt/keyrings/docker.gpg",
            "echo \"deb [arch=\"$(dpkg --print-architecture)\" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \"$(. /etc/os-release && echo \"$VERSION_CODENAME\")\" stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt-get update",
            "sudo apt-get install docker-ce docker-ce-cli -y containerd.io docker-buildx-plugin docker-compose-plugin",
            "sudo /bin/chmod 666 /var/run/docker.sock",

            # MySQL connectors installation
            "sudo apt update",
            "sudo apt install -y mysql-server",
            "sudo apt install mysql-client",

            # Node exporter readiness for Prometheus data scraping (port 9100)
            "sudo apt install net-tools"
        ]
    }
}

# Create elastic ip
# resource "aws_eip" "lb" {
#     vpc = true
# }

# Connecting between ec2 instance and elastic ip instance
# resource "aws_eip_association" "eip_assoc" {
#     instance_id = aws_instance.ec2.id
#     allocation_id = aws_eip.lb.id
# }

# Feedback with the public IP of the new EC2 instance
output "public_ip" {
    value = aws_instance.ec2.public_ip
}
