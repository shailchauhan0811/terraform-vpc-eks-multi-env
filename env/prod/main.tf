module "vpc" {
    source = "../../modules/vpc"
    vpc_cidr_block = var.vpc_cidr_block
    env = var.env
    public_subnets = var.public_subnets
    private_subnets = var.private_subnets
    project_name = var.project_name
}

module "eks" {
    source = "../../modules/eks"
    cluster_name = var.cluster_name
    kubernetes_version = var.kubernetes_version
    subnet_ids = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
    instance_types = var.instance_types
    desired_capacity = var.desired_capacity
    min_capacity = var.min_capacity
    max_capacity = var.max_capacity
}