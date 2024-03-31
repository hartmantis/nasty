resource "grafana_dashboard" "smart" {
  config_json = file("${path.module}/grafana_dashboards/smart.json")
}
