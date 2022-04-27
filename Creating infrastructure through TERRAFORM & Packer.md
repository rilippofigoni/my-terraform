# Creating infrastructure through TERRAFORM & Packer on AWS

## Installation

- Download Terraform binary for linux [https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip](https://releases.hashicorp.com/terraform/1.1.9/terraform_1.1.9_linux_amd64.zip)
- Unzip to get binary “terraform”
- set the PATH variable to point to terraform binary directory

### create a simple EC2 Instance, Open the port 8080 and create a html file on the server

Terraform file : main.tf

```
provider "aws" {.   <-- Provider information , AWS,
  region = "us-west-2"   <-- AWS Region
  access_key = "*****"   <--- API user access key
  secret_key = "******"     <--- API user secret key
}

resource "aws_instance" "example" {  <--- Creating an AWS EC2 Instance
  ami           = "ami-06f2f779464715dc5"    <-- AMI Image , Here we can use Packer generated Image from previous post
  instance_type = "t2.micro"  <--- Machine configuration
  vpc_security_group_ids = [aws_security_group.instance.id]
  associate_public_ip_address = "true"   <---- Whether Public IP need
  user_data = <<-EOF                      <----- Script that needs to be executed after provisioning the machine. This feature is provided by AWS EC2 itself
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &              <--- Ubuntu already comes busy box installed
              EOF

  tags = {
    Name = "terraform-example"          <---Name Tag associated with machine
  }
}

resource "aws_security_group" "instance" {   <---- Creating New Security group
  name = "terraform-example-instance"
  ingress {   <--- Opening Port 8080 for web application
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {. <--- Opening port 22 for SSH login
    from_port     = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {  <--- Output variable. This will print the value in the "terraform apply" command output
  value       = aws_instance.example.public_ip
  description = "The public IP of the web server"
}
```

Run the terraform commands

Initialize the TERRAFORM with AWS libraries. First create the main.tf file with AWS resources and execute the following init command

```
$ terraform init
```

PLAN command shows what terraform will ADD/DELETE/UPDATE through execution of TF file

```
$ terraform plan

....

Plan: 2 to add, 0 to change, 0 to destroy.
```

VALIDATE the terraform configuration files

```
$ terraform validate

Success! The configuration is valid.
```

Run the plan

```
$ terraform apply
....
Plan: 2 to add, 0 to change, 0 to destroy.
Do you want to perform these actions?  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.
Enter a value: yes
aws_security_group.instance: Creating...aws_security_group.instance: Creation complete after 1s [id=sg-02a8db439dccd9714]aws_instance.example: Creating...aws_instance.example: Still creating... [10s elapsed]aws_instance.example: Still creating... [20s elapsed]aws_instance.example: Creation complete after 20s [id=i-063ddb14204b08810]Apply complete! Resources: 2 added, 0 changed, 0 destroyed.
Outputs:public_ip = XX.XXX.XX.XX
```

Terraform creates the “terraform.tfstate” in the same directory as it executed. This contains the state. All the AWS resources and their IDs created.

To delete all the resources created before we can use the DESTROY command which will delete all the resources , found in the terraform.tfstate file

```
$ terraform destroy
....
Plan: 0 to add, 0 to change, 2 to destroy.
...
Destroy complete! Resources: 2 destroyed.
```

Ubuntu ssh login

```
$ ssh -I *****.pem ubuntu@ec2-54-XX-XXX-54.us-west-2.compute.amazonaws.com
```

testing the web application

```
$ curl http://ec2-54-XX-XXX-54.us-west-2.compute.amazonaws.com:8080
Hello, World
```

References :

1. [https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180](https://blog.gruntwork.io/an-introduction-to-terraform-f17df9c6d180)
2. [https://learn.hashicorp.com/terraform/getting-started/install.html](https://learn.hashicorp.com/terraform/getting-started/install.html)
3. [https://www.terraform.io/docs/providers/aws/r/instance.html](https://www.terraform.io/docs/providers/aws/r/instance.html)
4. [https://www.terraform.io/docs/providers/aws/index.html](https://www.terraform.io/docs/providers/aws/index.html)
5. [https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/user-data.html)