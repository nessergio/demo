resource "aws_eip" "nat" {}

resource "aws_nat_gateway" "one" {
  allocation_id = aws_eip.nat.id
  subnet_id = aws_subnet.cluster_public[0].id
  depends_on = [ aws_internet_gateway.one ]
}

# Create Internet Gateway
resource "aws_internet_gateway" "one" {
  vpc_id = aws_vpc.one.id
  tags   = { Name = "${local.name_prefix}_gw" }
}
