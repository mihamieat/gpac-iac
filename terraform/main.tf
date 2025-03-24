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

####################
### VPC resource ###
####################

resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "prod"
  }
}

#####################
### EC2 resources ###
#####################

resource "aws_instance" "app_fronted" {
  ami           = "ami-0359cb6c0c97c6607"
  instance_type = "t2.micro"
  key_name      = "gpac-admin-ssh"

  tags = {
    Name = "frontend"
  }
}

resource "aws_instance" "app_backend" {
  ami           = "ami-0359cb6c0c97c6607"
  instance_type = "t2.micro"
  key_name      = "gpac-admin-ssh"

  tags = {
    Name = "backend"
  }
}

resource "aws_instance" "database" {
  ami           = "ami-0359cb6c0c97c6607"
  instance_type = "t2.micro"
  key_name      = "gpac-admin-ssh"

  tags = {
    Name = "database"
  }
}
