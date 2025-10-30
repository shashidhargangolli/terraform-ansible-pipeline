provider "aws" {
  region = "ap-south-1"
}

# Security Group to allow SSH (22) and Tomcat (8080)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and Tomcat HTTP"

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow Tomcat HTTP"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# EC2 instance using existing key pair
resource "aws_instance" "Sha" {
  ami                    = "ami-07f07a6e1060cd2a8"  # Ubuntu 22.04 in ap-south-1
  instance_type          = "t3.micro"
  key_name               = "LinuxKeyPair"
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  tags = {
    Name = "TfAns-Instance"
  }

  # Save public IP locally for Ansible to use
  provisioner "local-exec" {
    command = "echo ${self.public_ip} > public_ip.txt"
  }
}
