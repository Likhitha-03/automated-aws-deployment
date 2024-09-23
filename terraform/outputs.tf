output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.new_instance.public_dns
}

output "ec2_private_key" {
  value     = tls_private_key.pk.private_key_pem
  sensitive = true  
}
