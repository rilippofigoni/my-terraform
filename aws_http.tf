provider "aws" {
  region = "us-east-2" 
  access_key = "AKIA2IBHXBLBYLSLMWPP"
  secret_key = "V5jOQYLHhGhUYoABQVPdBajPgyWJcCTSo0lt7Y5g" 
}

resource "aws_instance" "example" {
  ami           = "ami-097763ff009a896f3"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.instance.id]
  associate_public_ip_address = "true"
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080
              EOF

  tags = {
    Name = "terraform-example"
  }  
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

ingress {
    from_port     = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "The public IP of the web server"
}  