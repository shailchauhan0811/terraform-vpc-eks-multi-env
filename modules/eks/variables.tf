
variable "cluster_name" {
  description = "EKS cluster name"
  type        = string
}

variable "kubernetes_version" {
  description = "Kubernetes version for EKS"
  type        = string
 
}

variable "subnet_ids" {
  description = "Subnet IDs for EKS cluster and nodes"
  type        = list(string)
}

variable "instance_types" {
  description = "EC2 instance types for worker nodes"
  type        = list(string)
 
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
