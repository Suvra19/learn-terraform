provider "aws" {
  region = "ap-southeast-2"
}

resource "aws_instance" "example" {
  ami = "ami-09eebd0b9bd845bf1"
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.allow_traffic.id]

  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF


  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "allow_traffic" {
  name = "terraform-sg-instance"
  description = "Allow all inbound traffic"

  tags = {
    Name = "allow_traffic"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_vpc_security_group_ingress_rule" "allow_traffic_ipv4" {
  security_group_id = aws_security_group.allow_traffic.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = var.server_port
  ip_protocol       = "tcp"
  to_port           = var.server_port
}

variable "server_port" {
  description = "The port the server will use for HTTP requests"
  type = number
  default = 8080
}

output "public_ip" {
  value = aws_instance.example.public_ip
  description = "The public IP address of the webserver"
}
