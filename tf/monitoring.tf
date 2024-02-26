data "grafana_cloud_stack" "test" {
  provider = grafana.cloud
  slug     = var.grafana_cloud_slug
}
