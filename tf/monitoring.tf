resource "grafana_cloud_stack" "main" {
  provider = grafana.cloud

  name        = var.grafana_cloud_slug
  slug        = var.grafana_cloud_slug
  region_slug = var.grafana_cloud_region
}
