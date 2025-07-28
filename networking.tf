# networking.tf

# 1. VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block
  tags = {
    Name = "my-app-vpc"
  }
}

data "aws_availability_zones" "available" {
  state = "available"
}

# 2. Public Subnet 1
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block_1 # e.g., "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[0] # First AZ
  tags = {
    Name = "my-app-public-subnet-1"
  }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr_block_2 # e.g., "10.0.2.0/24"
  map_public_ip_on_launch = true
  availability_zone       = data.aws_availability_zones.available.names[1] # Second AZ
  tags = {
    Name = "my-app-public-subnet-2"
  }
}



# 3. Internet Gateway
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "my-app-igw"
  }
}

# 4. Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "my-app-public-route-table"
  }
}

# 5. Route Table Association for Public Subnet 1
resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public.id
}


# 5. Route Table Association for Public Subnet 2
resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public.id
}


# Private Subnet 1
resource "aws_subnet" "private_1" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block_1 # e.g., "10.0.10.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0] # First AZ
  map_public_ip_on_launch = false
  tags = {
    Name = "my-app-private-subnet-1"
  }
}

# Private Subnet 2
resource "aws_subnet" "private_2" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.private_subnet_cidr_block_2 # e.g., "10.0.11.0/24"
  availability_zone       = data.aws_availability_zones.available.names[1] # Second AZ
  map_public_ip_on_launch = false
  tags = {
    Name = "my-app-private-subnet-2"
  }
}

# NAT Gateway (for private subnets to access internet for updates/dependencies)
resource "aws_eip" "nat_gateway_eip" {
  domain = "vpc"
  tags = { Name = "my-app-nat-eip" }
}

resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat_gateway_eip.id
  subnet_id     = aws_subnet.public_1.id # NAT Gateway lives in a public subnet
  tags = {
    Name = "my-app-nat-gateway"
  }
  depends_on = [aws_internet_gateway.main]
}


resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }
  tags = { Name = "my-app-private-rt" }
}


# Private Route Table Association 1
resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.private_1.id
  route_table_id = aws_route_table.private.id
}

# Private Route Table Association 2
resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.private_2.id
  route_table_id = aws_route_table.private.id
}
