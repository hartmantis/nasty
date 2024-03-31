resource "grafana_dashboard" "smart" {
  provider = grafana.stack

  config_json = file("${path.module}/grafana_dashboards/smart.json")
}
