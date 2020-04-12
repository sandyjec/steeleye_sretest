variable "AWS_REGION" {
  default = "eu-west-1"
}

variable "PATH_TO_PRIVATE_KEY" {
  default = "id_rsa"
}

variable "PATH_TO_PUBLIC_KEY" {
  default = "id_rsa.pub"
}

variable "instance_count" {
  default = "2"
}

variable "AMIS" {
  type = map(string)
  default = {
    eu-west-1 = "ami-047bb4163c506cd98"
  }
}

