terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.16"
    }
  }

}

provider "aws" {

  region = var.region
}
//Apache + Jenkins on Master 
resource "aws_instance" "Jenkins_Master" {
  ami                    = var.ami
  instance_type          = var.instance_type
  vpc_security_group_ids = [var.vpc_security_group_ids]
  iam_instance_profile   = aws_iam_instance_profile.this.name
  subnet_id              = var.subnet_id
  user_data              = file("apache+jenkins.sh")
  key_name               = var.key_name
  tags = {
    Name = "Jenkins_Master"
  }

}

resource "aws_iam_role" "this" {
  name = "test_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Condition = {}
      },
    ]
  })
}

resource "aws_iam_instance_profile" "this" {

  role = aws_iam_role.this.name
  name = "profile-test"
}

resource "aws_iam_role_policy_attachment" "this" {

  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
  role       = aws_iam_role.this.name
}


