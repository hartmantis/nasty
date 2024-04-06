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

resource "grafana_dashboard" "node_info" {
  provider = grafana.stack

  config_json = templatefile(
    "${path.module}/grafana_dashboards/node_info.json.tftpl",
    {
      pressure = grafana_library_panel.node_exporter["Pressure"].panel_id
      cpu_busy = grafana_library_panel.node_exporter["CPU Busy"].panel_id
      sys_load = grafana_library_panel.node_exporter["Sys Load"].panel_id
      ram_used = grafana_library_panel.node_exporter["RAM Used"].panel_id
      swap_used = grafana_library_panel.node_exporter["SWAP Used"].panel_id
      root_fs_used = grafana_library_panel.node_exporter["Root FS Used"].panel_id
      cpu_cores = grafana_library_panel.node_exporter["CPU Cores"].panel_id
      uptime = grafana_library_panel.node_exporter["Uptime"].panel_id
      rootfs_total = grafana_library_panel.node_exporter["RootFS Total"].panel_id
      ram_total = grafana_library_panel.node_exporter["RAM Total"].panel_id
      swap_total = grafana_library_panel.node_exporter["SWAP Total"].panel_id
    }
  )
}
