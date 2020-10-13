terraform {
  backend "s3" {
    bucket = "terraform.webserver.fiaplabs.com"
    key    = "aws/infra"
    region = "us-east-2"
  }
}

resource "aws_vpc" "vpc_demo" {
  cidr_block = var.cidr

  tags = {
    project       = var.project
    turma         = var.turma
  }
} 

resource "aws_subnet" "subnet_demo" {
  vpc_id                    = aws_vpc.vpc_demo.id
  map_public_ip_on_launch   = true
  cidr_block                = var.cidr
  availability_zone         = "us-east-1a"


  tags = {
    project       = var.project
    turma         = var.turma
  }
}

resource "aws_internet_gateway" "igw_demo" {
  vpc_id    = aws_vpc.vpc_demo.id

  tags = {
    project       = var.project
    turma         = var.turma
  }
}

resource "aws_default_route_table" "route_demo" {
  default_route_table_id = aws_vpc.vpc_demo.default_route_table_id

  tags = {
    project       = var.project
    turma         = var.turma
    }

route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_demo.id
  }
}

