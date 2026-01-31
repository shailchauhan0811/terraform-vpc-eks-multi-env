resource "aws_vpc" "vpc" {
    cidr_block = var.vpc_cidr_block
    enable_dns_hostnames = true
    enable_dns_support   = true
    tags = {
        Name = "${var.project_name}-${var.env}-vpc"
        Environment = var.env
    }
}

data "aws_availability_zones" "azs" {
    state = "available"
}

resource "aws_subnet" "public_subnets" {
    vpc_id =  aws_vpc.vpc.id
    count = length(var.public_subnets)
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    cidr_block = var.public_subnets[count.index]
    map_public_ip_on_launch = true
    tags = {
        Name = "${var.project_name}-${var.env}-public-subnet-${count.index + 1}"
        "kubernetes.io/role/elb" = "1"
        "kubernetes.io/cluster/${var.project_name}-${var.env}-cluster" = "owned"
    }
}

resource "aws_subnet" "private_subnets" {
    vpc_id =  aws_vpc.vpc.id
    count = length(var.private_subnets)
    availability_zone = data.aws_availability_zones.azs.names[count.index]
    cidr_block = var.private_subnets[count.index]
    tags = {
        Name = "${var.project_name}-${var.env}-private-subnet-${count.index + 1}"
        "kubernetes.io/role/internal-elb" = "1"
        "kubernetes.io/cluster/${var.project_name}-${var.env}-cluster" = "owned"
    }
}

resource "aws_internet_gateway" "internet_gateway" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "${var.project_name}-${var.env}-igw"
    }
}

resource "aws_route_table" "public_route_table" {
    vpc_id = aws_vpc.vpc.id
    tags = {
      Name = "${var.project_name}-${var.env}-public-rt"
    }

   route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.internet_gateway.id
   }
}

resource "aws_eip" "nat" {
  count = length(var.public_subnets)

  domain = "vpc"
  depends_on = [aws_internet_gateway.internet_gateway]

  tags = {
    Name = "${var.project_name}-${var.env}-eip-${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  count = length(var.public_subnets)

  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public_subnets[count.index].id

  tags = {
    Name = "${var.project_name}-${var.env}-nat-${count.index + 1}"
  }

  depends_on = [aws_internet_gateway.internet_gateway]
}

resource "aws_route_table" "private_route_table" {
  count = length(var.private_subnets)

  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway[count.index].id
  }

  tags = {
    Name = "${var.project_name}-${var.env}-private-rt-${count.index + 1}"
  }
}

resource "aws_route_table_association" "private" {
  count = length(var.private_subnets)

  subnet_id      = aws_subnet.private_subnets[count.index].id
  route_table_id = aws_route_table.private_route_table[count.index].id
}

resource "aws_route_table_association" "public" {
  count = length(var.public_subnets)

  subnet_id      = aws_subnet.public_subnets[count.index].id
  route_table_id = aws_route_table.public_route_table.id
}