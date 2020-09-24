variable "key_name_home_work" {
  type = string
  default = "home_key_pair"
}

variable "path_to_public_key" {
  type = string
  default = "~/.ssh/id_rsa_aws_hillel.pub"
}

variable "path_to_private_key" {
  type = string
  default = "~/.ssh/id_rsa_aws_hillel"
}

variable "path_to_credentials_file" {
  type = string
  default = "~/.aws/credentials"
}
