data "aws_availability_zones" "available" {
  state = "available"
}
  

resource "aws_vpc" "main" {
  cidr_block = "10.2.0.0/16"
  enable_dns_hostnames=true

  tags = {
    Name = "own"
  }
}
resource "aws_subnet" "public" {
  vpc_id=aws_vpc.main.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block=element(var.public_cidr,count.index)
  availability_zone=element(data.aws_availability_zones.available.names,count.index)
  map_public_ip_on_launch=true
tags={
  Name="own-public-subnet-${count.index+1}"
}  
}
resource "aws_subnet" "private" {
   vpc_id=aws_vpc.main.id
  count = length(data.aws_availability_zones.available.names)
  cidr_block=element(var.private_cidr,count.index)
  availability_zone=element(data.aws_availability_zones.available.names,count.index)
tags={
  Name="own-private-subnet-${count.index+1}"
}  
}
resource "aws_subnet" "data"{
  count = length(data.aws_availability_zones.available.names)
   vpc_id=aws_vpc.main.id
  cidr_block=element(var.data_cidr,count.index)
  availability_zone=element(data.aws_availability_zones.available.names,count.index)
tags={
  Name="own-data-subnet-${count.index+1}"
}
}
resource "aws_internet_gateway" "gw" {
  vpc_id = aws_vpc.main.id
  tags={
    Name="internet_gateway"
  }  
}
resource "aws_eip" "eip" {
  vpc=true
  tags = {
    Name = "igw"
  }
}
resource "aws_nat_gateway" "natgw" {
  allocation_id =aws_eip.eip.id
  subnet_id =aws_subnet.public[0].id
  tags={
    Name="natgw"
  }
  }
  resource "aws_route_table" "public_ote" {
    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id = aws_internet_gateway.gw.id
   }
   tags = {
     "Name" = "public-route"
   }
  }
  resource "aws_route_table" "private_ote" {
    vpc_id = aws_vpc.main.id
    route {
      cidr_block = "0.0.0.0/0"
      gateway_id =aws_nat_gateway.natgw.id
   }
   tags = {
     "Name" = "private-route"
   }
  }
 resource "aws_route_table_association" "public"  {
     count=length(var.public_cidr)
     subnet_id =aws_subnet.public[count.index].id
route_table_id=aws_route_table.public_ote.id
 }
 resource "aws_route_table_association" "private" {
    count=length(var.private_cidr)
    subnet_id =aws_subnet.private[count.index].id
route_table_id=aws_route_table.private_ote.id
 }
 resource "aws_route_table_association" "data" {
    count=length(var.data_cidr)
    subnet_id = aws_subnet.data[count.index].id
route_table_id=aws_route_table.private_ote.id
 }

