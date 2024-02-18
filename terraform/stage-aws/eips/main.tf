resource "aws_eip" "public-eip" {
  count            = var.number_of_eips
  vpc              = true
  public_ipv4_pool = "amazon"

  tags = {
    Name      = "${var.client_name}-${var.env_type}-eip${count.index + 1}-nlb"
    Client    = var.client_name
    CreatedBy = "Terraform"
    Terraform = "true"
  }
}
