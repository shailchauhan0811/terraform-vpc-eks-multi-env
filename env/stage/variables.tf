variable "vpc_cidr_block" {}

variable "env" {}

variable "public_subnets" {}

variable "private_subnets" {}

variable "project_name" {}

variable "aws_region" {}

variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
}
variable "kubernetes_version" {

}

variable "desired_capacity" {
  description = "Desired number of worker nodes"
  type        = number
}

variable "min_capacity" {
  description = "Minimum worker nodes"
  type        = number
}

variable "max_capacity" {
  description = "Maximum worker nodes"
  type        = number
}
