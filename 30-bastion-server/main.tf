# open source module with aws contribution
# 2 AZ = us-east-1a, us-east-1b
# using 2AZ bastion servers are integrating with 2AZ of frontend, backend, mysql servers 

#bastion-1 server
module "ec2_instance" {
  source  = "terraform-aws-modules/ec2-instance/aws"

  ami = data.aws_ami.rhel9.id
  name = local.resource_name #expense-dev-bastion

  instance_type = "t3.micro"

  # bastion security group from 20-sg
  vpc_security_group_ids = [local.bastion_sg_id]

  # us-east-1a(10.0.1.0 - 10.0.1.255)/24 = 256 private ip addresses availability zone bastion-expense-dev server 
  subnet_id = local.bastion_subnet_ids[0] 
  

  create_security_group = false 

  tags = merge(
    var.common_tags,
    var.bastion_tags,
    {
      Name = "${local.resource_name}-1"
    }
  )
}


# # bastion-2 server
# module "ec2_instance1" {
#   source  = "terraform-aws-modules/ec2-instance/aws"

#   name = "${local.resource_name}-2" # expense-dev-bastion-1
#   ami = data.aws_ami.rhel9.id
#   instance_type = "t3.micro"
#   vpc_security_group_ids = [local.bastion_sg_id]
#   subnet_id = local.bastion_subnet_ids[1] # us-east-1b availability zone bastion-expense-dev-1 server

#   create_security_group = false 

#   tags = merge(
#     var.common_tags,
#     var.bastion_tags,
#     {
#       Name = "${local.resource_name}-2"
#     }
#   )
# }