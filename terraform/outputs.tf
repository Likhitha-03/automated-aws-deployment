output "ec2_public_ip" {
  value = aws_instance.your_ec2_instance.public_ip
}

output "ec2_username" {
  value = "ec2-user" 
}
