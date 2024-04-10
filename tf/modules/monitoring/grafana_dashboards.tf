data "http" "grafana_dashboard_node_exporter" {
  url = "https://grafana.com/api/dashboards/1860/revisions/${var.grafana_dashboard_node_exporter_revision}/download"
}

locals {
  panels_orig = [for panel in jsondecode(data.http.grafana_dashboard_node_exporter.response_body).panels : panel if panel.type != "row"]

  panels_updated = {
    for panel in local.panels_orig : panel.title => merge(
      panel,
      {
        targets = [
          for target in panel.targets : merge(
            target, {
              expr = replace(replace(target.expr, "instance", "node"), "$job", "integrations/node_exporter")
            }
          )
        ]
      }
    )
  }
}

resource "grafana_dashboard" "node_exporter" {
  provider = grafana.stack

  config_json = data.http.grafana_dashboard_node_exporter.response_body
}

resource "grafana_library_panel" "node_exporter" {
  provider = grafana.stack

  for_each = local.panels_updated

  name       = each.key
  model_json = jsonencode(each.value)
}

resource "grafana_dashboard" "node_info" {
  provider = grafana.stack

  config_json = templatefile(
    "${path.module}/grafana_dashboards/node_info.json.tftpl",
    {
      pressure     = grafana_library_panel.node_exporter["Pressure"].uid
      cpu_busy     = grafana_library_panel.node_exporter["CPU Busy"].uid
      sys_load     = grafana_library_panel.node_exporter["Sys Load"].uid
      ram_used     = grafana_library_panel.node_exporter["RAM Used"].uid
      swap_used    = grafana_library_panel.node_exporter["SWAP Used"].uid
      root_fs_used = grafana_library_panel.node_exporter["Root FS Used"].uid
      cpu_cores    = grafana_library_panel.node_exporter["CPU Cores"].uid
      uptime       = grafana_library_panel.node_exporter["Uptime"].uid
      rootfs_total = grafana_library_panel.node_exporter["RootFS Total"].uid
      ram_total    = grafana_library_panel.node_exporter["RAM Total"].uid
      swap_total   = grafana_library_panel.node_exporter["SWAP Total"].uid
    }
  )
}
