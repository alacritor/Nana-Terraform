provider "aws" {
    region = "eu-central-1"
    profile = "default"
}

variable vpc_cidr_block {}
variable subnet_cidr_block {}
variable avail_zone {}
variable env_prefix {}
variable my_ip {}
variable instance_type {}
variable public_key_location {}



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


data "aws_ami" "latest-amazon-linux-image" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]
    }
    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

output "aws-ami-id" {
    value = data.aws_ami.latest-amazon-linux-image.id
}

output "ec2_public_ip" {
    value = aws_instance.myapp-server.public_ip
}

resource "aws_key_pair" "ssh-key" {
    key_name = "server-key"
    public_key = file(var.public_key_location)
}


resource "aws_instance" "myapp-server" {
    ami = data.aws_ami.latest-amazon-linux-image.id
    instance_type = var.instance_type

    subnet_id = aws_subnet.myapp-subnet-1.id
    vpc_security_group_ids = [aws_default_security_group.default-sg.id]
    availability_zone = var.avail_zone

    associate_public_ip_address = true
    key_name = aws_key_pair.ssh-key.key_name

    user_data = <<EOF
    #!/bin/bash
    sudo yum update -y && sudo yum install docker -y
    sudo systemctl start docker
    sudo usermod -aG docker ec2-user
    docker run -p 8080:80 nginx
    EOF

    user_data_replace_on_change = true       

    tags = {
        Name: "${var.env_prefix}-server"
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