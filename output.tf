output "wordpress_url" {
  description = "Public URL to access the WordPress site"
  value       = "http://${aws_lb.wp_alb.dns_name}"
}
