output "instance_public_dns" {
  description = "The public DNS of the EC2 instance"
  value       = aws_instance.new_instance.public_dns
}


