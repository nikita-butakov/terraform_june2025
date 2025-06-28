# ---------- Provider ----------
provider "aws" {
  region = var.aws_region
}

# ---------- EC2 Instances ----------

resource "aws_instance" "ec2_Front" {
  ami                         = var.ami_name
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.SG-Front.id]
  key_name                    = var.key_name
  associate_public_ip_address = true
  iam_instance_profile        = "EC2CloudWatchPutMetrics"

  tags = {
    Name = "Frontend"
  }

  user_data = templatefile("${path.module}/scripts/nginx_front.sh", {
    aws_region = var.aws_region
  })
}

resource "aws_instance" "ec2_Back" {
  ami                         = var.ami_name
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public_subnet.id
  vpc_security_group_ids      = [aws_security_group.SG-Back.id]
  key_name                    = var.key_name
  associate_public_ip_address = true

  tags = {
    Name = "Backend"
  }

  user_data = file("${path.module}/scripts/nginx_back.sh")
}

# ---------- Network ----------

resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "${var.aws_region}a"

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id

  tags = {
    Name = "main-igw"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

resource "aws_route_table_association" "public_rt_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}


# ---------- Security Group ----------

resource "aws_security_group" "SG-Front" {
 name        = "SG-Front"
 description = "Allow HTTPS,SSH to web server"
 vpc_id      = aws_vpc.main_vpc.id

ingress {
   description = "HTTP ingress"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }
 
ingress {
   description = "SSH ingress"
   from_port   = 22
   to_port     = 22
   protocol    = "tcp"
   cidr_blocks = ["0.0.0.0/0"]
 }

egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

}

resource "aws_security_group" "SG-Back" {
 name        = "SG-Back"
 description = "Allow HTTP from Front to Back"
 vpc_id      = aws_vpc.main_vpc.id

ingress {
   description = "HTTP ingress"
   from_port   = 80
   to_port     = 80
   protocol    = "tcp"
   security_groups = [aws_security_group.SG-Front.id]
 }
 
egress {
   from_port   = 0
   to_port     = 0
   protocol    = "-1"
   cidr_blocks = ["0.0.0.0/0"]
 }

}

# ---------- Outputs ----------

output "frontend_public_ip" {
  description = "Public IP of the Frontend EC2 instance"
  value       = aws_instance.ec2_Front.public_ip
}

output "backend_public_ip" {
  description = "Public IP of the Backend EC2 instance"
  value       = aws_instance.ec2_Back.public_ip
}


