data "http" "grafana_dashboard_node_exporter" {
  url = "https://grafana.com/api/dashboards/1860/revisions/${var.grafana_dashboard_node_exporter_revision}/download"
}

resource "grafana_dashboard" "node_exporter" {
  provider = grafana.stack

  config_json = data.http.grafana_dashboard_node_exporter.response_body
}

resource "grafana_library_panel" "node_exporter" {
  provider = grafana.stack

  for_each   = {
    for panel in jsondecode(data.http.grafana_dashboard_node_exporter.response_body).panels : panel.title => panel
  }
  name       = each.key
  model_json = jsonencode(each.value)
}
