terraform { 
  cloud { 
    
    organization = "test_sasha" 

    workspaces { 
      name = "test" 
    } 
  } 
}

provider "aws" {
  region = "us-east-1" # Change this to your desired region
}

resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "SashaVPC"
  }
}

resource "aws_subnet" "main_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a" # Change this to your desired AZ
  tags = {
    Name = "SashaSubnet"
  }
}

resource "aws_security_group" "allow_all" {
  vpc_id = aws_vpc.main_vpc.id
  name   = "sasha_allo_all_sg"

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" # All traffic
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowAllSG"
  }
}

resource "aws_instance" "main_instance" {
  ami           = "ami-08c40ec9ead489470" # Replace with an appropriate AMI ID for your region
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.main_subnet.id
  associate_public_ip_address = false
  vpc_security_group_ids = [
    aws_security_group.allow_all.id
  ]
  tags = {
    Name       = "SashaInstance2"
    team       = "platform"
    product    = "global"
    service    = "merchantview"
    created-by = "terraform"
    is-prod    = "false"
  }
  metadata_options {
    http_tokens = "required"
  }

}
