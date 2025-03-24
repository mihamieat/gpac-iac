terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}

resource "aws_key_pair" "gpac-admin-ssh" {
  key_name   = "gpac-admin-ssh"
  public_key = var.ssh_admin_public_key
}

resource "aws_instance" "app_server" {
  ami           = "ami-0359cb6c0c97c6607"
  instance_type = "t2.micro"
  key_name      = aws_key_pair.gpac-admin-ssh.key_name

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
