terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }

  required_version = ">= 1.5.0"
}

provider "aws" {
  access_key                  = "admin"
  secret_key                  = "admin"
  region                      = "us-east-1"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true
  skip_region_validation      = true

  endpoints {
    ec2 = "http://localhost:4566"
  }
}

locals {
  instance_name = "observabilidade-ec2"

  ami_id = "ami-61ad6e59d7b0"
}

resource "aws_security_group" "observabilidade_sg" {
  name        = "observabilidade-sg"
  description = "Security Group da aplicacao de observabilidade"

  ingress {
    description = "API"
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Grafana"
    from_port   = 3001
    to_port     = 3001
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Internet"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "observabilidade" {
  ami           = local.ami_id
  instance_type = "t3.micro"

  security_groups = [
    aws_security_group.observabilidade_sg.name
  ]

  user_data = <<-EOF
    #!/bin/bash

    set -e

    echo "Inicializando EC2 de observabilidade..." > /tmp/init.log

    mkdir -p /opt/observabilidade

    echo "EC2 pronta para receber o deploy." \
      > /opt/observabilidade/status.txt
  EOF

  tags = {
    Name        = "local.instance_name"
    Environment = "dev"
    Project     = "desafio-observabilidade"
  }
}

output "instance_id" {
  description = "ID da EC2 criada no localstack"
  value       = aws_instance.observabilidade.public_ip
}

output "instance_public_ip" {
  description = "IP publico da EC2 no localstack"
  value = aws_instance.observabilidade.public_ip
}

output "instance_private_ip" {
  description = "IP privado da EC2 no localstack"
  value = aws_instance.observabilidade.private_ip
}
