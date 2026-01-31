# Multi-Environment EKS Infrastructure with Terraform

This repository contains Terraform configurations for deploying Amazon EKS clusters across multiple environments (staging and production) with a modular architecture.

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    Multi-Environment EKS Setup                  │
├─────────────────────────────────────────────────────────────────┤
│  🏢 Production Environment    │  🧪 Staging Environment         │
│  ├── VPC (10.0.0.0/16)       │  ├── VPC (10.0.0.0/16)          │
│  ├── EKS Cluster (2 nodes)   │  ├── EKS Cluster (1 node)       │
│  ├── Public/Private Subnets  │  ├── Public/Private Subnets     │
│  └── NAT Gateways            │  └── NAT Gateways               │
└─────────────────────────────────────────────────────────────────┘
```

## 📁 Project Structure

```
terraform-vpc-eks-multi-env/
├── env/
│   ├── stage/                    # Staging Environment
│   │   ├── backend.tf           # S3 backend configuration
│   │   ├── main.tf              # Module calls
│   │   ├── variables.tf         # Variable definitions
│   │   ├── terraform.tfvars     # Staging values
│   │   ├── outputs.tf           # Output definitions
│   │   └── provider.tf          # AWS provider config
│   └── prod/                     # Production Environment
│       ├── backend.tf           # S3 backend configuration
│       ├── main.tf              # Module calls
│       ├── variables.tf         # Variable definitions
│       ├── terraform.tfvars     # Production values
│       ├── outputs.tf           # Output definitions
│       └── provider.tf          # AWS provider config
├── modules/
│   ├── vpc/                      # VPC Module
│   │   ├── main.tf              # VPC resources
│   │   ├── variables.tf         # VPC variables
│   │   └── outputs.tf           # VPC outputs
│   └── eks/                      # EKS Module
│       ├── main.tf              # EKS cluster & node groups
│       ├── variables.tf         # EKS variables
│       └── outputs.tf           # EKS outputs
├── .gitignore                    # Git ignore rules
└── README.md                     # This file
```

## 🚀 Features

- ✅ **Multi-Environment Support** - Separate staging and production environments
- ✅ **Modular Architecture** - Reusable VPC and EKS modules
- ✅ **Remote State Management** - S3 backend with DynamoDB locking
- ✅ **High Availability** - Multi-AZ deployment across 3 availability zones
- ✅ **Security** - Private subnets for worker nodes, public subnets for load balancers
- ✅ **Scalability** - Auto-scaling node groups with configurable capacity
- ✅ **LoadBalancer Support** - Proper subnet tagging for AWS Load Balancer Controller

## 📋 Prerequisites

Before you begin, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [AWS CLI](https://aws.amazon.com/cli/) configured with appropriate permissions
- [kubectl](https://kubernetes.io/docs/tasks/tools/) for cluster management
- AWS account with permissions to create EKS, VPC, and IAM resources

### Required AWS Resources

Create these resources before deployment:

```bash
# Create S3 bucket for Terraform state
aws s3 mb s3://ihub-terraform-statefile --region ap-south-1

# Create DynamoDB table for state locking
aws dynamodb create-table \
  --table-name ihub-table \
  --attribute-definitions AttributeName=LockID,AttributeType=S \
  --key-schema AttributeName=LockID,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5 \
  --region ap-south-1
```

## 🛠️ Deployment

### Deploy Staging Environment

```bash
# Navigate to staging environment
cd env/stage

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

### Deploy Production Environment

```bash
# Navigate to production environment
cd env/prod

# Initialize Terraform
terraform init

# Review the plan
terraform plan

# Deploy infrastructure
terraform apply
```

## 🔧 Configuration

### Environment-Specific Settings

| Setting | Staging | Production |
|---------|---------|------------|
| **Cluster Name** | ihub-stage-cluster | ihub-prod-cluster |
| **Node Capacity** | 1 (desired) | 2 (desired) |
| **Instance Type** | t3.medium | t3.medium |
| **VPC CIDR** | 10.0.0.0/16 | 10.0.0.0/16 |
| **Kubernetes Version** | 1.32 | 1.32 |

### Customization

To customize the deployment, modify the `terraform.tfvars` file in the respective environment directory:

```hcl
# Example: env/stage/terraform.tfvars
vpc_cidr_block = "10.0.0.0/16"
aws_region = "ap-south-1"
env = "stage"
project_name = "ihub"
cluster_name = "ihub-stage-cluster"
kubernetes_version = "1.32"
instance_types = ["t3.medium"]
desired_capacity = 1
min_capacity = 1
max_capacity = 3
```

## 🌐 Accessing Your Clusters

### Configure kubectl

```bash
# For staging
aws eks update-kubeconfig --region ap-south-1 --name ihub-stage-cluster

# For production
aws eks update-kubeconfig --region ap-south-1 --name ihub-prod-cluster
```

### Verify Connection

```bash
# Check nodes
kubectl get nodes

# Check cluster info
kubectl cluster-info

# View all resources
kubectl get all --all-namespaces
```

## 📊 Monitoring and Management

### View Cluster Status

```bash
# Get cluster details
aws eks describe-cluster --name ihub-stage-cluster --region ap-south-1

# Check node group status
aws eks describe-nodegroup \
  --cluster-name ihub-stage-cluster \
  --nodegroup-name ihub-stage-cluster-ng \
  --region ap-south-1
```

### Switch Between Environments

```bash
# List available contexts
kubectl config get-contexts

# Switch to staging
kubectl config use-context arn:aws:eks:ap-south-1:ACCOUNT:cluster/ihub-stage-cluster

# Switch to production
kubectl config use-context arn:aws:eks:ap-south-1:ACCOUNT:cluster/ihub-prod-cluster
```

## 🔒 Security Considerations

- **Private Subnets**: Worker nodes are deployed in private subnets
- **IAM Roles**: Least privilege access for EKS cluster and node groups
- **Encryption**: EBS volumes are encrypted by default
- **Network Security**: Security groups restrict access appropriately
- **State Security**: Terraform state is encrypted in S3

## 🧹 Cleanup

To destroy the infrastructure:

```bash
# Destroy staging
cd env/stage
terraform destroy

# Destroy production
cd env/prod
terraform destroy
```

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Troubleshooting

### Common Issues

**Issue**: `Backend configuration changed`
```bash
# Solution: Reconfigure backend
terraform init -reconfigure
```

**Issue**: `LoadBalancer stuck in pending`
```bash
# Solution: Check subnet tags for ALB support
aws ec2 describe-subnets --filters "Name=tag:kubernetes.io/role/elb,Values=1"
```

**Issue**: `Node group creation fails`
```bash
# Solution: Check IAM permissions and subnet configuration
aws iam list-attached-role-policies --role-name ihub-stage-cluster-node-role
```

## 📞 Support

For questions and support:
- Create an issue in this repository
- Check AWS EKS documentation
- Review Terraform AWS provider documentation

---

**Built with ❤️ using Terraform and AWS EKS**