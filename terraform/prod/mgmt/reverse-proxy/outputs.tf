output "Public-ip-address" {
  value = var.reserve_public_eip_address? aws_eip.public-eip[0].public_ip : aws_instance.ec2-instance.public_ip
}

output "Private-ip-address" {
  value = aws_instance.ec2-instance.private_ip
}

output "SSH-Key-name" {
  value = aws_instance.ec2-instance.key_name
}
