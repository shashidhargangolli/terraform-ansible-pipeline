provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "my_instance" {
  ami           = "ami-07f07a6e1060cd2a8"
  instance_type = "t2.micro"
  tags = {
    Name = "Terraform-Instance"
  }
}

