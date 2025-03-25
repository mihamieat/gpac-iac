output "frontend_ip" {
  description = "The public IP of the frontend Ec2 instance"
  value       = aws_instance.app_fronted.public_ip
}

output "backend_ip" {
  description = "The public IP of the backend Ec2 instance"
  value       = aws_instance.app_backend.public_ip
}

output "database_ip" {
  description = "The public IP of the database EC2 instance"
  value       = aws_instance.database.public_ip
}
