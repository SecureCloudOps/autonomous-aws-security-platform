#checkov:skip=CKV2_AWS_11: VPC Flow Logs enabled in enterprise tier; skipped in resume demo to control cost/noise. CloudTrail provides API auditability.
resource "aws_vpc" "this" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = merge(
    var.tags,
    {
      Name = "secure-demo-vpc"
    }
  )
}

resource "aws_subnet" "private" {
  count = length(var.private_subnet_cidrs)

  vpc_id                  = aws_vpc.this.id
  cidr_block              = var.private_subnet_cidrs[count.index]
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name                                        = "private-subnet-${count.index}"
      "kubernetes.io/cluster/${var.cluster_name}" = "shared"
      "kubernetes.io/role/internal-elb"           = "1"
    }
  )
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "private-rt"
    }
  )
}

resource "aws_route_table_association" "private" {
  count = length(aws_subnet.private)

  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

resource "aws_subnet" "public_nat" {
  vpc_id                  = aws_vpc.this.id
  cidr_block              = "10.0.100.0/24"
  map_public_ip_on_launch = false

  tags = merge(
    var.tags,
    {
      Name = "public-nat-subnet"
    }
  )
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = merge(
    var.tags,
    {
      Name = "vpc-igw"
    }
  )
}

resource "aws_eip" "nat" {
  domain = "vpc"

  tags = merge(
    var.tags,
    {
      Name = "nat-eip"
    }
  )
}

resource "aws_nat_gateway" "this" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_nat.id

  tags = merge(
    var.tags,
    {
      Name = "nat-gateway"
    }
  )

  depends_on = [aws_internet_gateway.this]
}

resource "aws_route" "private_nat_egress" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.this.id
}

resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.this.id

  ingress = []
  egress  = []

  tags = merge(var.tags, { Name = "default-sg-locked-down" })
}

