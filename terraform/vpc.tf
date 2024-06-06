# Create VPC
resource "aws_vpc" "one" {
  cidr_block = var.cidr_block_ipv4
  tags       = { Name = "${local.name_prefix}_vpc" }
}

# --------------------- SECURITY GROUP ---------------------------------------

resource "aws_security_group" "public" {
  name        = "${replace(local.name_prefix, "_", "-")}-sg-public"
  description = "Allow Web and SSH inbound traffic"
  vpc_id      = aws_vpc.one.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
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
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = { Name = "sg_public" }
}

# ----------------------------------------------------------------------------