output "load_balancer_url" {
  value = "http://${aws_lb.nginx-load-balancer.dns_name}"
}