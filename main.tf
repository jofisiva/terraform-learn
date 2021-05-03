
provider "aws" {
  region = "eu-west-2"
}


resource "aws_vpc" "myapp-vpc" {
   cidr_block = var.vpc_cidr_block
   tags = {
     "Name" = "${var.env_prefix}-vpc"
   }
}
module "myapp-subnet" {
  source = "./modules/subnet"
  avail_zone = var.avail_zone
  default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id
  env_prefix = var.env_prefix
  subnet_cidr_block = var.subnet_cidr_block
  vpc_id = aws_vpc.myapp-vpc.id
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
  vpc_id = aws_vpc.myapp-vpc.id
  image_name = var.image_name
  subnet_id = module.myapp-subnet.subnet.id
}
