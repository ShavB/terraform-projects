/*
  1. create VPC
  2. Create 1 subnet
  3. Create route tables
  4. Associate subnet to the RT
  5. Attach Internet Gateway
  6. Create SG (22, 80)
  7. Create ec2 instance (ubuntu)
  Action :  SSH into ec2 instance &&
            Access nginx server on port 80

*/

# Create aws VPC
resource "aws_vpc" "vpc" {
  cidr_block = var.vpc-cidr

  tags = merge(
    var.tags,
    {
      Name    = "${var.region}-VPC"
      Service = "VPC"
    }
  )
}

# Create Subnet in VPC
resource "aws_subnet" "subnet" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = var.subnet-cidr

  tags = merge(
    var.tags,
    {
      Name    = "${var.region}-subnet"
      Service = "Subnet"
    }
  )
}

# Create Route tables
resource "aws_route_table" "rt" {
  vpc_id = aws_vpc.vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = merge(
    var.tags,
    {
      Name    = "${var.region}-rt"
      Service = "route-table"
    }
  )
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      Name    = "${var.region}-igw"
      Service = "aws_internet_gateway"
    }
  )
}

# Create Route Table association
resource "aws_route_table_association" "rt-a" {
  subnet_id      = aws_subnet.subnet.id
  route_table_id = aws_route_table.rt.id
}

# Create security group

resource "aws_security_group" "sg" {
  name        = "security_group"
  description = "Allow SSH and HTTP port"
  vpc_id      = aws_vpc.vpc.id

  tags = merge(
    var.tags,
    {
      Name    = "${var.region}-sg"
      Service = "security_group"
    }
  )
}

resource "aws_vpc_security_group_ingress_rule" "allow_http" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_ingress_rule" "allow_ssh" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}

resource "aws_vpc_security_group_egress_rule" "allow_all_traffic" {
  security_group_id = aws_security_group.sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}

# Create EC2 instance
resource "aws_instance" "ec2" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.sg.id]
  subnet_id                   = aws_subnet.subnet.id
  key_name                    = var.key-pair-name
  user_data                   = local.instance-user-data
}
