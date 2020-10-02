output "public_ip_staging" {
  value = aws_instance.staging.public_ip
  description = "The public IP address of the staging server instance."
}
output "public_ip_production" {
  value = aws_instance.production.public_ip
  description = "The public IP address of the production server instance."
}