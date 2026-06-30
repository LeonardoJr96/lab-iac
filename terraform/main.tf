terraform {
   required_version = ">= 1.6.0"

   required_providers {
      aws = {
         source  = "hashicorp/aws"
         version = "~> 5.0"
      }
      local = {
         source  = "hashicorp/local"
         version = "~> 2.5"
    }
   }
}

provider "aws" {
   region = var.aws_region
}

data "aws_vpc" "default" {
   default = true
}

data "aws_subnets" "default" {
   filter {
      name   = "vpc-id"
      values = [data.aws_vpc.default.id]
   }
}

resource "aws_security_group" "nodes_sg" {
   name        = "${var.project_name}-sg"
   description = "SSH externo e tráfego interno entre os nós"
   vpc_id      = data.aws_vpc.default.id

   ingress {
      description = "SSH do seu computador"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = [var.allowed_ssh_cidr]
   }

   ingress {
      description = "Comunicação interna entre os servidores"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      self        = true
   }

   egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
   }

   tags = {
      Name = "${var.project_name}-sg"
   }
}

locals {
  nodes = {
    "cp-1"       = { role = "control-plane" }
    "worker-fe"  = { role = "frontend" }
    "worker-be1" = { role = "backend" }
    "worker-be2" = { role = "backend" }
  }
}

resource "aws_instance" "nodes" {
   for_each = local.nodes

   ami                         = var.ami_id
   instance_type               = each.value.role == "control-plane" ? "t3.medium" : "t3.small"
   key_name                    = var.key_name
   subnet_id                   = data.aws_subnets.default.ids[0]
   vpc_security_group_ids      = [aws_security_group.nodes_sg.id]
   associate_public_ip_address = true

   tags = {
      Name = "${var.project_name}-${each.key}"
      Role = each.value.role
   }
}