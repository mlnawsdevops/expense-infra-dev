 # open source module with aws contribution
# 2 AZ = us-east-1a, us-east-1b
# using 2AZ bastion servers are integrating with 2AZ of frontend, backend, mysql servers 

resource "aws_key_pair" "openvpn" {
    key_name = "openvpn"
    public_key = file("~/.ssh/openvpn.pub")
  
}

# vpn-1 server
module "vpn" {
  source  = "terraform-aws-modules/ec2-instance/aws"
    key_name = aws_key_pair.openvpn.key_name
  ami = local.ami_id
  name = local.resource_name #expense-dev-vpn

  instance_type = "t3.micro"

  # bastion security group from 20-sg
  vpc_security_group_ids = [local.vpn_sg_id]

  # us-east-1a(10.0.1.0 - 10.0.1.255)/24 = 256 private ip addresses availability zone bastion-expense-dev server 
  subnet_id = local.vpn_subnet_id
  
  create_security_group = false 

  tags = merge(
    var.common_tags,
    var.vpn_tags,
    {
      Name = local.resource_name
    }
  )
}
