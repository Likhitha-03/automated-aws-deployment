provider "aws" {
  region = "us-east-1"
}

resource "aws_s3_bucket" "tf_state" {
  bucket = "my-terraform-state-bucket-likky"  
  acl    = "private"
  tags = {
    Name = "Terraform State Bucket"
  }
}

resource "aws_dynamodb_table" "tf_lock" {
  name         = "terraform-lock-table"
  billing_mode = "PAY_PER_REQUEST"
  attribute {
    name = "LockID"
    type = "S"
  }
  tags = {
    Name = "Terraform Lock Table"
  }
}

# Terraform backend configuration
terraform {
  backend "s3" {
    bucket         = aws_s3_bucket.tf_state.bucket
    key            = "terraform/state"
    region         = "us-east-1"
    dynamodb_table = aws_dynamodb_table.tf_lock.name
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
  ami                    = "ami-0ebfd941bbafe70c6"  
  instance_type          = "t2.micro"
  subnet_id              = aws_subnet.new_subnet.id
  vpc_security_group_ids = [aws_security_group.new_sg.id]
  availability_zone      = "us-east-1a"
  key_name               = aws_key_pair.kp.key_name

  tags = {
    Name = "MyEC2Instance"
  }
}


resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "kp" {
  key_name   = "myKey"
  public_key = tls_private_key.pk.public_key_openssh
}

resource "local_file" "ssh_key" {
  filename = "${aws_key_pair.kp.key_name}.pem"
  content  = tls_private_key.pk.private_key_pem
}
