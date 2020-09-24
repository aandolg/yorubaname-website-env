output "public_ip" {
  value = aws_instance.jenkins.public_ip
  description = "The public IP address of the jenkins server instance."
}