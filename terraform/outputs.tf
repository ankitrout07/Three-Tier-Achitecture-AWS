# External ALB DNS
output "external_alb_dns_name" {
  description = "The DNS name of the external load balancer"
  value       = aws_lb.external_alb.dns_name
}

# Internal ALB DNS
output "internal_alb_dns_name" {
  description = "The DNS name of the internal load balancer"
  value       = aws_lb.internal_alb.dns_name
}

# Aurora Endpoint
output "database_endpoint" {
  description = "The cluster endpoint of the Aurora database"
  value       = aws_rds_cluster.aurora.endpoint
}
