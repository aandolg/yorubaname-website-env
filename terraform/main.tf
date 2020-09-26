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

resource "aws_security_group" "allow_ssh" {
  name        = "allow_ssh"
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
    Name = "allow_ssh"
  }
}

resource "aws_security_group" "allow_http" {
  name        = "allow_http"
  description = "Allow ssh inbound traffic"
  ingress {
    description = "TLS from VPC"
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
    Name = "allow_http"
  }
}

resource "aws_security_group" "allow_https" {
  name        = "allow_https"
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
    Name = "allow_https"
  }
}

resource "aws_key_pair" "generated_key_home" {
  key_name   = var.key_name_home_work
  public_key =  file(var.path_to_public_key)
}


resource "aws_instance" "jenkins" {
  ami           = data.aws_ami.amzn2_instance.id
  instance_type = local.workspace["instance_type"]
  key_name      = aws_key_pair.generated_key_home.key_name
  vpc_security_group_ids = [
    aws_security_group.allow_ssh.id,
    aws_security_group.allow_http.id,
    aws_security_group.allow_https.id
  ]
  root_block_device {
    volume_size = 16
  }

  provisioner "local-exec" {
    command = "echo ${aws_instance.jenkins.private_ip} > private_ips && echo ${aws_instance.jenkins.public_ip} > public_ip && echo \" ssh ec2-user@${aws_instance.jenkins.public_ip}\""
  }

  provisioner "remote-exec" {
    inline = [
      "sudo fallocate --length 2GiB /swapfile",
      "sudo chmod 600 /swapfile",
      "sudo mkswap /swapfile",
      "sudo swapon /swapfile",
      "sudo bash -c \"echo '/swapfile     swap     swap     defaults     0     0' >> /etc/fstab\""
    ]
    connection {
      type     = "ssh"
      user     = "ec2-user"
      password = ""
      host     = aws_instance.jenkins.public_ip
      private_key = file(var.path_to_private_key)
    }
  }
  tags = {
    Name = "Jenkins main instance"
  }
}
