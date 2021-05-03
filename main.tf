

terraform {
  required_version = ">= 0.12"
  backend "s3" {
    bucket = "terraform-bucket-myapp"
    key = "myapp/state.tfstate"
  }
}
provider "aws" {
  region = "eu-west-2"
}


resource "aws_vpc" "myapp-vpc" {
   cidr_block = var.vpc_cidr_block
   tags = {
     "Name" = "${var.env_prefix}-vpc"
   }
}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.vpc_cidr_block

  azs             = [var.avail_zone]
  public_subnets  = [var.subnet_cidr_block]

  public_subnet_tags ={Name = "${var.env_prefix}-subnet-1"}
  tags = {
    name = "${var.env_prefix}-vpc"
  }

}

module "myapp-webserver" {
  source = "./modules/webserver"
  avail_zone = var.avail_zone
  env_prefix = var.env_prefix
  instance_type = var.instance_type
  my_ip = var.my_ip
  private_key = var.private_key
  public_key = var.public_key
  public_key_location = var.public_key_location
  vpc_id = module.vpc.vpc_id
  image_name = var.image_name
  subnet_id = module.vpc.public_subnets[0]
}
