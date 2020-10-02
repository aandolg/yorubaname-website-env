data "aws_ami" "amzn2_instance" {
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200904.0-x86_64-gp2*"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["137112412989"] # Canonical
}

data "aws_ami" "centos" {
  most_recent = true
  filter {
    name   = "name"
    values = ["CentOS Linux 7 x86_64 HVM EBS *"]
  }
  owners = ["679593333241"]
}

resource "aws_security_group" "allow_ssh_public_server" {
  name        = "allow_ssh_public_server"
  description = "Allow ssh inbound traffic"
  ingress {
    description = "TLS from VPC"
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
    Name = "allow_ssh_public_server"
  }
}

resource "aws_security_group" "allow_http_public_server" {
  name        = "allow_http_public_server"
  description = "Allow ssh inbound traffic"
  ingress {
    description = "TLS from VPC"
    from_port   = 80e
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
    Name = "allow_http_public_server"
  }
}

resource "aws_security_group" "allow_https_public_server" {
  name        = "allow_https_public_server"
  description = "Allow ssh inbound traffic"
  ingress {
    description = "TLS from VPC"
    from_port   = 443
    to_port     = 443
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
    Name = "allow_https_public_server"
  }
}

resource "aws_key_pair" "generated_key_home_public_server" {
  key_name   = var.key_name_home_work
  public_key =  file(var.path_to_public_key)
}


resource "aws_instance" "staging" {
  ami           = data.aws_ami.amzn2_instance.id
  instance_type = local.workspace["instance_type"]
  key_name      = aws_key_pair.generated_key_home_public_server.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh_public_server.id,
    aws_security_group.allow_http_public_server.id,
    aws_security_group.allow_https_public_server.id
  ]
  root_block_device {
    volume_size = 8
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.staging.private_ip} > private_ips_staging && echo ${aws_instance.staging.public_ip} > public_ip_staging"
  }
  tags = {
    Name = "Staging main instance"
  }
}

resource "aws_instance" "production" {
  ami           = data.aws_ami.amzn2_instance.id
  instance_type = local.workspace["instance_type"]
  key_name      = aws_key_pair.generated_key_home_public_server.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh_public_server.id,
    aws_security_group.allow_http_public_server.id,
    aws_security_group.allow_https_public_server.id
  ]
  root_block_device {
    volume_size = 8
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.production.private_ip} > private_ips_production && echo ${aws_instance.production.public_ip} > public_ip_production"
  }
  tags = {
    Name = "Production main instance"
  }
}