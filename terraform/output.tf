output "frontend_public_ips" {
  description = "Public IP addresses of the frontend instances"
  value       = aws_instance.app_fronted[*].public_ip
}

output "backend_ip" {
  description = "The public IP of the backend Ec2 instance"
  value       = aws_instance.app_backend.public_ip
}

output "database_ip" {
  description = "The public IP of the database EC2 instance"
  value       = aws_instance.database.public_ip
}

output "database_private_ip" {
  description = "The private IP of the database EC2 instance"
  value       = aws_instance.database.private_ip
}
