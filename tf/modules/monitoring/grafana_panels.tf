resource "grafana_library_panel" "disks_unhealthy" {
  provider = grafana.stack

  name       = "Unhealthy Disks"
  model_json = file("${path.module}/grafana_panels/disks_unhealthy.json")
}

resource "grafana_library_panel" "disks_errors" {
  provider = grafana.stack

  name       = "Disk Errors"
  model_json = file("${path.module}/grafana_panels/disks_errors.json")
}

resource "grafana_library_panel" "zfs_pool_health" {
  provider = grafana.stack

  name       = "ZFS Pool Health"
  model_json = file("${path.module}/grafana_panels/zfs_pool_health.json")
}
