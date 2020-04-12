resource "aws_instance" "appserver" {
  count         = "2"
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.nano"
  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name
tags = {
  name = "appserver${count.index}"
}
}

output "ips" {
  value = ["${aws_instance.appserver.*.public_ip}"]
}

resource "aws_instance" "webserver" {
  ami           = "ami-035966e8adab4aaad"
  instance_type = "t2.nano"
  # the VPC subnet
  subnet_id = aws_subnet.main-public-1.id

  # the security group
  vpc_security_group_ids = [aws_security_group.allow-ssh.id]

  # the public SSH key
  key_name = aws_key_pair.mykeypair.key_name
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install nginx",
      "sudo service nginx start",
    ]
    connection {
        type="ssh"
        user="ubuntu"
        private_key = file("./insert your private key path or file name")
        host=self.public_ip
   }
  }
tags = {
  name = "webserver"
}
}

output "ip" {
  value = ["${aws_instance.webserver.public_ip}"]
}


