output "Allocated_EIPs" {
  value = aws_eip.public-eip.*.id
}

output "Allocated_EIPs_Private_IPs" {
  value = aws_eip.public-eip.*.private_ip
}

output "Allocated_EIPs_Public_IPs" {
  value = aws_eip.public-eip.*.public_ip
}
