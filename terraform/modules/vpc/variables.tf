variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "private_subnet_cidrs" {
  description = "List of CIDR blocks for private subnets"
  type        = list(string)
}

variable "tags" {
  description = "Tags applied to all VPC resources"
  type        = map(string)
}

variable "cluster_name" {
  description = "EKS cluster name used for subnet discovery tags"
  type        = string
}

variable "enable_nat_gateway" {
  description = "Enable NAT Gateway for outbound internet access"
  type        = bool
  default     = true
}
