data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, var.az_count)
}

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_hostnames = true
  enable_dns_support   = true
  tags = {
    Name = "portfolio-${var.env}-vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "portfolio-${var.env}-igw"
  }
}

# Public subnets (ALB, NAT Gateways)
resource "aws_subnet" "public" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "portfolio-${var.env}-public-${local.azs[count.index]}"
    Type = "public"
  }
}

# App subnets (ECS tasks)
resource "aws_subnet" "app" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 4)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "portfolio-${var.env}-app-${local.azs[count.index]}"
    Type = "app"
  }
}

# DB subnets (no internet; internal only)
resource "aws_subnet" "db" {
  count                   = var.az_count
  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(var.vpc_cidr, 4, count.index + 8)
  availability_zone       = local.azs[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "portfolio-${var.env}-db-${local.azs[count.index]}"
    Type = "db"
  }
}

# NAT Gateways (one per AZ in public subnets)
resource "aws_eip" "nat" {
  count  = var.az_count
  domain = "vpc"
  tags = {
    Name = "portfolio-${var.env}-nat-eip-${count.index}"
  }
}

resource "aws_nat_gateway" "main" {
  count         = var.az_count
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name = "portfolio-${var.env}-nat-${local.azs[count.index]}"
  }
  depends_on = [aws_internet_gateway.main]
}

# Route table: public -> IGW
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "portfolio-${var.env}-public-rt"
  }
}

resource "aws_route_table_association" "public" {
  count          = var.az_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Route table: app -> NAT (one per AZ so each app subnet uses its AZ's NAT)
resource "aws_route_table" "app" {
  count  = var.az_count
  vpc_id = aws_vpc.main.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main[count.index].id
  }
  tags = {
    Name = "portfolio-${var.env}-app-rt-${local.azs[count.index]}"
  }
}

resource "aws_route_table_association" "app" {
  count          = var.az_count
  subnet_id      = aws_subnet.app[count.index].id
  route_table_id = aws_route_table.app[count.index].id
}

# Route table: DB (no internet; local only)
resource "aws_route_table" "db" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "portfolio-${var.env}-db-rt"
  }
}

resource "aws_route_table_association" "db" {
  count          = var.az_count
  subnet_id      = aws_subnet.db[count.index].id
  route_table_id = aws_route_table.db.id
}
