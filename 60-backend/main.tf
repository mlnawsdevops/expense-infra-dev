## session-37
# 1. create ec2-instance for backend
# 2. configure the instance using ansible 
# 3. null resource and connect instance using remote provisioners and file provisioners.
# 4. stop the instance using resource "aws_ec2_instance_state"
# 5. take the instance ami using "aws_ami_from_instance"
# 6. delete the instance using null resource and aws command line arguments and local exec.
# 7. 

module "backend" {
  source  = "terraform-aws-modules/ec2-instance/aws"
  ami = local.ami_id
  name = local.resource_name #expense-dev-backend

  instance_type = "t3.micro"

  # bastion security group from 20-sg
  vpc_security_group_ids = [local.backend_sg_id]

  # us-east-1a(10.0.1.0 - 10.0.1.255)/24 = 256 private ip addresses availability zone bastion-expense-dev server 
  subnet_id = local.private_subnet_id
  
  create_security_group = false 

  tags = merge(
    var.common_tags,
    var.backend_tags,
    {
      Name = local.resource_name
    }
  )
}

# null resource it won't create any resources. just using for provisioners connection
resource "null_resource" "backend" {
  # Changes to any instance of the cluster requires re-provisioning
  triggers = {
    instance_id = module.backend.id
  }

  # Bootstrap script can run on any instance of the cluster
  # So we just choose the first in this case
  connection {
    host = module.backend.private_ip
    type = "ssh"
    user = "ec2-user"
    password = "DevOps321"
  }

  provisioner "file" {
    source = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    # Bootstrap script called with private_ip of each node in the cluster
    inline = [
      "chmod +x /tmp/backend.sh",
      "sudo sh /tmp/backend.sh ${var.backend_tags.Component} ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = module.backend.id
  state       = "stopped"
  depends_on = [null_resource.backend]
}

resource "aws_ami_from_instance" "backend" {
  name               = local.resource_name
  source_instance_id = module.backend.id
  depends_on = [aws_ec2_instance_state.backend]
}

resource "null_resource" "delete_backend" {
  triggers = {
    instance_id = module.backend.id
  }

  provisioner "local-exec" {
    # aws command to terminate ec2 instances
    command = "aws ec2 terminate-instances --instance-ids ${module.backend.id}"
  }
  depends_on = [aws_ami_from_instance.backend]
}

