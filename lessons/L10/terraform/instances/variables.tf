
variable "template" {
  description = "Template para criar a instancia"
  type        = string
  default     = "ubuntu"
}

variable "ami" {
  description = "AWS instance ami"
  type        = string
  default     = "ami-0817d428a6fb68645"
}

variable "project" {
  type    = string
  default = "demo"
}

variable "turma" {
  type    = string
  default = "2TRCR"
}

variable "rm" {
  type    = string
}

variable "vpc_id" {
  type	    = string
}

#variable "subnet_id" {
#  type	    = "string"
#}