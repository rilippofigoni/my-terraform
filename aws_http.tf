provider "aws" {.   <-- Provider information , AWS,
  region = "us-west-2"   <-- AWS Region
  access_key = "*****"   <--- API user access key
  secret_key = "******"     <--- API user secret key  
}

resource "aws_instance" "example" {  <--- Creating an AWS EC2 Instance 
  ami           = "ami-06f2f779464715dc5"    <-- AMI Image , Here we can use Packer generated Image from previous post
  instance_type = "t2.micro"  <--- Machine configuration
  vpc_security_group_ids = [aws_security_group.instance.id]
  associate_public_ip_address = "true"   <---- Whether Public IP need
  user_data = <<-EOF                      <----- Script that needs to be executed after provisioning the machine. This feature is provided by AWS EC2 itself
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &              <--- Ubuntu already comes busy box installed
              EOF

  tags = {
    Name = "terraform-example"          <---Name Tag associated with machine
  }
}

resource "aws_security_group" "instance" {   <---- Creating New Security group 
  name = "terraform-example-instance"
  ingress {   <--- Opening Port 8080 for web application
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {. <--- Opening port 22 for SSH login
    from_port     = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {  <--- Output variable. This will print the value in the "terraform apply" command output
  value       = aws_instance.example.public_ip
  description = "The public IP of the web server"