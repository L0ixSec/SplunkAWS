provider "aws" {
  region = "eu-west-2"
}

variable "DDNS_NAME" {
  description = "The DDNS name to use for CIDR block"
  type        = string
}

resource "aws_instance" "splunk_instance" {
  ami           = "ami-0c55b159cbfafe1f0"  # Amazon Linux 2 AMI (free-tier eligible)
  instance_type = "t2.micro"
  key_name      = "l0ix"  # Your key name

  tags = {
    Name = "SplunkInstance"
  }

  # Security Group to allow SSH and HTTP
  vpc_security_group_ids = [aws_security_group.splunk_sg.id]
}

resource "aws_security_group" "splunk_sg" {
  name        = "splunk_security_group"
  description = "Allow SSH and HTTP access"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.DDNS_NAME]  # Use the variable directly
  }

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = [var.DDNS_NAME]  # Use the variable directly
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "ec2_instance_public_ip" {
  value = aws_instance.splunk_instance.public_ip
}
