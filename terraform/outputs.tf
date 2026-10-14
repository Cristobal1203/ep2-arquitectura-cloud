output "alb_url" {
  description = "URL publica del Application Load Balancer"
  value       = "http://${aws_lb.alb.dns_name}"
}

output "rds_endpoint" {
  description = "Host del servidor RDS MySQL Multi-AZ"
  value       = aws_db_instance.mysql.address
}

output "eks_cluster_name" {
  description = "Nombre del cluster Amazon EKS"
  value       = aws_eks_cluster.main.name
}