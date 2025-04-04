terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.89.0"
    }
  }

  required_version = ">= 1.2.0"
}

provider "aws" {
  region = "eu-west-3"
}
#############
## AZ data ##
#############

data "aws_availability_zones" "available" {
  state = "available"
}

####################
### VPC resource ###
####################

resource "aws_vpc" "production" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "production"
  }
}

#####################
## Subnet Resouces ##
#####################

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.production.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "eu-west-3a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.production.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "eu-west-3a"

  tags = {
    Name = "private-subnet"
  }
}

resource "aws_subnet" "frontend_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.production.id
  cidr_block              = element(["10.0.10.0/24", "10.0.11.0/24"], count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "subnet-az${count.index + 1}"
  }
}

######################
## Internet Gateway ##
######################

resource "aws_internet_gateway" "prod_igw" {
  vpc_id = aws_vpc.production.id

  tags = {
    Name = "prod-internet-gateway"
  }
}

##################
## Route tables ##
##################

resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.production.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.prod_igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "frontend_subnet_association" {
  count          = 2
  subnet_id      = aws_subnet.frontend_subnet[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}

#########
## ALB ##
#########

module "alb" {
  source              = "./module/alb"
  vpc_id              = aws_vpc.production.id
  security_groups     = [aws_security_group.public_sg.id]
  subnet_ids          = aws_subnet.frontend_subnet[*].id
  health_check_path   = "/"
  target_instance_ids = aws_instance.app_fronted[*].id
  certificate_arn     = var.certificate_arn
}

#####################
## Security Groups ##
#####################

resource "aws_security_group" "public_sg" {
  vpc_id = aws_vpc.production.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "public-sg"
  }
}

resource "aws_security_group" "db_sg" {
  vpc_id = aws_vpc.production.id

  ingress {
    from_port   = 27017
    to_port     = 27017
    protocol    = "tcp"
    cidr_blocks = ["10.0.1.0/24"] # Only allow access from the public subnet
  }

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [var.db_admin_ip]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}


#####################
### EC2 resources ###
#####################

resource "aws_instance" "app_fronted" {
  ami                    = "ami-0160e8d70ebc43ee1" # Ubuntu 24.04 x86
  count                  = 2
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.frontend_subnet[count.index].id
  availability_zone      = data.aws_availability_zones.available.names[count.index]
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = "gpac-admin-ssh"

  tags = {
    Name = "frontend-server-az${count.index + 1}"
  }
}

resource "aws_instance" "app_backend" {
  ami                    = "ami-0160e8d70ebc43ee1" # Ubuntu 24.04 x86
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.public_sg.id]
  key_name               = "gpac-admin-ssh"

  tags = {
    Name = "backend"
  }
}

resource "aws_instance" "database" {
  ami                    = "ami-0160e8d70ebc43ee1" # Ubuntu 24.04 x86
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.db_sg.id]
  key_name               = "gpac-admin-ssh"

  tags = {
    Name = "database"
  }
}
