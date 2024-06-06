variable "cidr_block_ipv4" {
  type    = string
  default = "172.16.0.0/16"
}

variable "registry" {
  type    = string  
  default = ""
}

locals {
  cluster_name = "eks-demo"
  n_zones      = length(data.aws_availability_zones.available.names)
  name_prefix  = "${var.tags["Environment"]}_${var.tags["Project"]}"
}