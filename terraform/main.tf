provider "aws" {
  region = "us-east-1"
}

terraform {
  backend "s3" {
    bucket         = "terraform-statefile-bucket-likky"
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock-likky"
    encrypt        = true
  }
}

resource "aws_vpc" "new_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyNewVPC"
  }
}

resource "aws_subnet" "new_subnet" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "MyNewSubnet"
  }
}

resource "aws_internet_gateway" "new_igw" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_route_table" "new_route_table" {
  vpc_id = aws_vpc.new_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.new_igw.id
  }
  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "new_route_table_association" {
  subnet_id      = aws_subnet.new_subnet.id
  route_table_id = aws_route_table.new_route_table.id
}

resource "aws_security_group" "new_sg" {
  vpc_id = aws_vpc.new_vpc.id
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
    cidr_blocks = ["0.0.0.0/0"]  
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "MySecurityGroup"
  }
}

resource "aws_instance" "new_instance" {
  ami                    = var.ami  
  instance_type          = var.instance_type 
  subnet_id              = aws_subnet.new_subnet.id  
  vpc_security_group_ids = [aws_security_group.new_sg.id]
  availability_zone      = "us-east-1a"
  key_name               = "automated-aws-deployment-key"

  tags = {
    Name = "MyNewEC2Instance"
  }
}
