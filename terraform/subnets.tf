# Creating subnets for EKS cluster
resource "aws_subnet" "cluster_private" {
  count                   = local.n_zones
  vpc_id                  = aws_vpc.one.id
  cidr_block              = cidrsubnet(
    aws_vpc.one.cidr_block, 
    8,                    # using 8 bit for net index
    10 + count.index      # net index will be 10 + zone index
  )
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  tags                    = { 
    Name                              = "${local.name_prefix}_subnet_priv_${count.index}" 
    "kubernetes.io/role/internal-elb" = "1"
    "kubernetes.io/cluster/eks-demo"  = "owned"
  }
}

resource "aws_subnet" "cluster_public" {
  count                   = local.n_zones
  vpc_id                  = aws_vpc.one.id
  cidr_block              = cidrsubnet(
    aws_vpc.one.cidr_block, 
    8,                    # using 8 bit for net index
    20 + count.index      # net index will be 10 + zone index
  ) 
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true
  tags                    = { 
    Name                             = "${local.name_prefix}_subnet_pub_${count.index}" 
    "kubernetes.io/role/elb"         = "1"
    "kubernetes.io/cluster/eks-demo" = "owned"
  }
}

# Create Routing Table for private subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.one.id
  # The routing table will have only default gateways
  route {
    cidr_block = "0.0.0.0/0" # IPv4
    gateway_id = aws_nat_gateway.one.id
  }
  tags = { Name = "${local.name_prefix}_private_rt" }
}


# Create Routing Table for public suubnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.one.id
  # The routing table will have only default gateways
  route {
    cidr_block = "0.0.0.0/0" # IPv4
    gateway_id = aws_internet_gateway.one.id
  }
  tags = { Name = "${local.name_prefix}_public_rt" }
}

# Associate Subnet with Routing Table
resource "aws_route_table_association" "private" {
  count          = local.n_zones
  subnet_id      = aws_subnet.cluster_private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Associate Subnet with Routing Table
resource "aws_route_table_association" "public" {
  count          = local.n_zones
  subnet_id      = aws_subnet.cluster_public[count.index].id
  route_table_id = aws_route_table.public.id
}