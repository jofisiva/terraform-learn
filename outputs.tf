
output "aws_public_ip" {
  value = module.myapp-webserver.instance.public_ip
}