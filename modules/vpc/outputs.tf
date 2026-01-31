output "vpc_id" {
    value = aws_vpc.vpc.id
}

output "private_subnet_ids" {
    value = aws_subnet.private_subnets[*].id
}

output "public_subnet_ids" {
    value = aws_subnet.public_subnets[*].id
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.internet_gateway.id
}

output "nat_gateway_ids" {
  description = "IDs of the NAT Gateways"
  value       = aws_nat_gateway.nat_gateway[*].id
}