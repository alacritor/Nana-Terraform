provider "aws" {
    region = "us-east-1"
    profile = "default"
}

variable "cidr_blocks" {
    description = "cidr blocks and name tags for vpc and subnets"
    type = list(object({
        cidr_block = string
        name = string
    }))    
}


resource "aws_vpc" "developement-vpc" {
    cidr_block = var.cidr_blocks[0].cidr_block
    tags = {
        Name = var.cidr_blocks[0].name
    } 
}


resource "aws_subnet" "dev-subnet-1" {
    vpc_id = aws_vpc.developement-vpc.id
    cidr_block = var.cidr_blocks[1].cidr_block
    availability_zone = "us-east-1a"
    tags = {
        Name = var.cidr_blocks[1].name
    }
}



output "dev-vpc-id" {
    value = aws_vpc.developement-vpc.id
}


output "dev-subnet-1-id" {
    value = aws_subnet.dev-subnet-1.id
}


# variable "vpc_cidr_block" {
#    description = "vpc cidr block"
# }

# variable "environment" {
#    description = "deployment environment"
# }




# data "aws_vpc" "existing_vpc" {
#    default = true
# }


# resource "aws_subnet" "dev-subnet-2" {
#    vpc_id = data.aws_vpc.existing_vpc.id
#    cidr_block = "172.31.96.0/20"
#    availability_zone = "us-east-1a"
#    tags = {
#        Name = "Nana-Test-Default-Subnet-2"
#    }
# }



# Configure the Linode Provider
# provider "linode" {
#   token = "..."
# } 