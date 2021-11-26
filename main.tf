terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = var.region
#   shared_credentials_file = "$HOME/.aws/credentials"
#   profile                 = "labprofile"
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
      Name = "dev"
  }
}
 resource "aws_internet_gateway" "IGW" {    
    vpc_id =  aws_vpc.main.id
 }
 resource "aws_subnet" "publicsubnets" {
   vpc_id =  aws_vpc.main.id
   cidr_block = "${var.public_subnets}"
 }
 resource "aws_subnet" "privatesubnets" {
   vpc_id =  aws_vpc.main.id
   cidr_block = "${var.private_subnets}"
 }
 resource "aws_route_table" "PublicRT" {
    vpc_id =  aws_vpc.main.id
         route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.IGW.id
     }
 }
 resource "aws_route_table" "PrivateRT" {
   vpc_id = aws_vpc.main.id
   route {
   cidr_block = "0.0.0.0/0"
   nat_gateway_id = aws_nat_gateway.NATgw.id
   }
 }
 resource "aws_route_table_association" "PublicRTassociation" {
    subnet_id = aws_subnet.publicsubnets.id
    route_table_id = aws_route_table.PublicRT.id
 }
 resource "aws_route_table_association" "PrivateRTassociation" {
    subnet_id = aws_subnet.privatesubnets.id
    route_table_id = aws_route_table.PrivateRT.id
 }
 resource "aws_eip" "nateIP" {
   vpc   = true
 }
 resource "aws_nat_gateway" "NATgw" {
   allocation_id = aws_eip.nateIP.id
   subnet_id = aws_subnet.publicsubnets.id
 }