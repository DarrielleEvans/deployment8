
# configure aws provider
provider "aws" {
  access_key = var.access_key
  secret_key = var.secret_key
  region = "us-east-1"
}



# create instance
resource "aws_instance" "jenkins_man" {
  ami = var.ami
  instance_type = "t2.micro"
  associate_public_ip_address = true
  vpc_security_group_ids = [var.defaultsg]
  key_name = "d8"

  user_data = "${file("deployjenkins.sh")}"

  tags = {
    "Name" : "d8_Jenkins_instance"
  }

}

# create instance
resource "aws_instance" "terraform" {
  ami = var.ami
  instance_type = "t2.micro"
  associate_public_ip_address = true

  vpc_security_group_ids = [var.defaultsg]
  key_name = "d8"
  user_data = "${file("deployterraform.sh")}"

  tags = {
    "Name" : "d8_Terraform"
  }

}

# create instance
resource "aws_instance" "docker" {
  ami = var.ami
  instance_type = "t2.medium"
  associate_public_ip_address = true
  vpc_security_group_ids = [var.defaultsg]
  key_name = "d8"
  user_data = "${file("deploydocker.sh")}"

  tags = {
    "Name" : "d8_Docker"
  }

}


output "instance_ip" {
  value = aws_instance.jenkins_man.public_ip

}

output "instance_ip2" {
  value = aws_instance.terraform.public_ip
}

output "instance_ip3" {
  value = aws_instance.docker.public_ip
}