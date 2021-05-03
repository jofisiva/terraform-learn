
output "aws_ami_id" {
  value = data.aws_ami.latest-amazon-linux-image.id
}
output "aws_public_ip" {
  value = aws_instance.my-app-server.public_ip
}