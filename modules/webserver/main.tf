resource "aws_security_group" "myapp-sg" {

  vpc_id = var.vpc_id
  name = "myapp-sg"
  ingress {
    from_port = 22
    protocol = "tcp"
    to_port = 22
    cidr_blocks = [var.my_ip]
  }
  ingress {
    from_port = 8080
    protocol = "tcp"
    to_port = 8080
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
    prefix_list_ids = []
  }
  tags = {
    Name:"${var.env_prefix}-default-sg"
  }
}

data "aws_ami" "latest-amazon-linux-image" {
  most_recent = true
  owners = ["amazon"]
  filter {
    name = "name"
    values = [var.image_name]
  }
  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}


resource "aws_key_pair" "ssh-key" {
  key_name = "terraform-file"
  public_key = var.public_key//file(var.public_key_location)
  //var.public_key
}

resource "aws_instance" "my-app-server" {
  ami = data.aws_ami.latest-amazon-linux-image.id
  instance_type = var.instance_type

  subnet_id = var.subnet_id
  vpc_security_group_ids = [aws_security_group.myapp-sg.id]
  availability_zone = var.avail_zone

  //connection {
  //  type = "ssh"
  //  host = self.public_ip
  //  user = "ec2-user"
  //  private_key = var.private_key
  //}
  //  provisioner "remote-exec" {
  //    inline = [
  //      "export ENV=dev",
  //      "mkdir newdir"
  //    ]
  //  }
  associate_public_ip_address = true
  key_name = aws_key_pair.ssh-key.key_name
  user_data =  <<-EOF
                #!/bin/bash
               sudo yum update -y && sudo yum install -y docker
               sudo systemctl start docker
               sudo usermod -aG docker ec2-user
               docker run -p 8080:80 nginx
           EOF

  tags = {
    "Name" = "${var.env_prefix}-server"
  }
}