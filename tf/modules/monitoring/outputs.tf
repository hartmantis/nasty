output "grafana_cloud_stack_url" {
  value = grafana_cloud_stack.main.url
}
output "grafana_cloud_stack_service_account_token" {
  value = grafana_cloud_stack_service_account_token.tf.key
}
