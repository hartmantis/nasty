output "grafana_cloud_stack_url" {
  value     = grafana_cloud_stack.main.url
  sensitive = true
}
output "grafana_cloud_stack_service_account_token" {
  value     = grafana_cloud_stack_service_account_token.tf.key
  sensitive = true
}
