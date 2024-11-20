provider "aws" {
    region = "eu-central-1"
    profile = "default"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}

resource "aws_vpc" "myapp-vpc" {
    cidr_block = var.vpc_cidr_block
    tags = {
        Name: "${var.env_prefix}-vpc"
    }
}

resource "aws_subnet" "myapp-subnet-1" {
    vpc_id = aws_vpc.myapp-vpc.id
    cidr_block = var.subnet_cidr_block
    availability_zone = var.avail_zone
        tags = {
        Name: "${var.env_prefix}-subnet-1"
    }
}


# resource "aws_route_table" "myapp-route-table" {    
#     vpc_id = aws_vpc.myapp-vpc.id

#     route {
#         cidr_block = "0.0.0.0/0"
#         gateway_id = aws_internet_gateway.myapp-igw.id
#     }
#     tags = {
#         Name: "${var.env_prefix}-rtb"
#     }
# }


resource "aws_internet_gateway" "myapp-igw" {
    vpc_id = aws_vpc.myapp-vpc.id
    tags = {
        Name: "${var.env_prefix}-igw"
    }
}

resource "aws_default_route_table" "main-rtb" {
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.myapp-igw.id
    }
    tags = {
        Name: "${var.env_prefix}-main-rtb"
    }
}

resource "aws_default_security_group" "default-sg" {
    vpc_id = aws_vpc.myapp-vpc.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "TCP"
        cidr_blocks = [var.my_ip]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "TCP"
        cidr_blocks = ["0.0.0.0/0"]
    }    

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
        prefix_list_ids = []
    }


    tags = {
        Name: "${var.env_prefix}-default-sg"
    }
}


# resource "aws_route_table_association" "a-rtb-subnet" {
#     subnet_id = aws_subnet.myapp-subnet-1.id
#     route_table_id = aws_route_table.myapp-route-table.id
# }





# variable "cidr_blocks" {
#     description = "cidr blocks and name tags for vpc and subnets"
#     type = list(object({
#         cidr_block = string
#         name = string
#     }))    
# }


# resource "aws_vpc" "developement-vpc" {
#     cidr_block = var.cidr_blocks[0].cidr_block
#     tags = {
#         Name = var.cidr_blocks[0].name
#     } 
# }


# resource "aws_subnet" "dev-subnet-1" {
#     vpc_id = aws_vpc.developement-vpc.id
#     cidr_block = var.cidr_blocks[1].cidr_block
#     availability_zone = "us-east-1a"
#     tags = {
#         Name = var.cidr_blocks[1].name
#     }
# }



# output "dev-vpc-id" {
#     value = aws_vpc.developement-vpc.id
# }


# output "dev-subnet-1-id" {
#     value = aws_subnet.dev-subnet-1.id
# }


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